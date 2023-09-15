# frozen_string_literal: true

module Jira
  class JiraIssueAdapter < BaseFlowAdapter
    include Singleton
    include Rails.application.routes.url_helpers

    def process_issue(jira_account, jira_issue, product, project)
      issue_key = jira_issue_attrs(jira_issue)['key']
      return if issue_key.blank?

      demand = Demand.where(company_id: project.company.id, external_id: issue_key).first_or_initialize
      project_in_jira = Jira::JiraReader.instance.read_project(jira_issue_attrs(jira_issue), jira_account) || project

      update_demand!(demand, jira_account, jira_issue, project_in_jira, product)
      process_product_changes(jira_issue_changelog(jira_issue))
      read_comments(demand, jira_issue.attrs)
      define_contract(demand, jira_account, jira_issue.attrs)
      read_portfolio_unit(demand, jira_issue)

      demand
    end

    def process_jira_issue_changelog(jira_account, jira_issue_changelog, demand, demand_creator)
      read_demand_details(demand, jira_account, jira_issue_changelog, demand_creator)

      process_labels(demand, jira_issue_changelog['values'])

      DemandEffortService.instance.build_efforts_to_demand(demand)
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.warn('Record not unique')
      Jira::JiraApiError.create(demand: demand)
      nil
    rescue ActiveRecord::StaleObjectError
      Rails.logger.warn('Register locked')
      Jira::JiraApiError.create(demand: demand)
      nil
    end

    private

    def jira_issue_attrs(jira_issue)
      jira_issue.attrs
    end

    def jira_issue_changelog(jira_issue)
      return {} unless jira_issue.respond_to?(:changelog)

      jira_issue.changelog
    end

    def update_demand!(demand, jira_account, jira_issue, project, product)
      customer = define_customer(project, jira_account, jira_issue_attrs(jira_issue))
      class_of_service = Jira::JiraReader.instance.read_class_of_service(demand, jira_account, jira_issue_attrs(jira_issue), jira_issue_changelog(jira_issue))
      demand.update(project: project, company: project.company, product: product, team: project.team,
                    customer: customer,
                    created_date: issue_fields_value(jira_issue, 'created'),
                    work_item_type: read_issue_type(demand.company, jira_issue_attrs(jira_issue)),
                    class_of_service: class_of_service,
                    demand_title: issue_fields_value(jira_issue, 'summary'),
                    external_url: build_jira_url(jira_account, demand.external_id), commitment_date: nil, discarded_at: nil)
    end

    def read_demand_details(demand, jira_account, jira_issue_changelog, demand_creator)
      read_responsibles_info(demand, jira_account, jira_issue_changelog)

      read_blocks(demand, jira_issue_changelog)
      read_transitions(demand, jira_issue_changelog, demand_creator)
    end

    def read_blocks(demand, jira_issue_changelog)
      transitions_history = sort_histories_fields(jira_issue_changelog, 'flagged')

      transitions_history.each do |history|
        process_demand_block(demand, history, history)
      end
    end

    def process_product_changes(jira_issue_changelog)
      return unless hash_has_histories?(jira_issue_changelog)

      sorted_histories = jira_issue_changelog['histories'].sort_by { |history_hash| Time.zone.parse(history_hash['created']) }
      history_array = jira_field_hash(sorted_histories, 'Key')

      history_array.each do |history|
        from_key = history['fromString']

        demand = Demand.find_by(external_id: from_key)

        demand.destroy if demand.present?
      end
    end

    def process_labels(demand, jira_issue_changelog)
      labels_field = jira_issue_changelog.map { |inside_hash| inside_hash['items'].select { |h| h['field'] == 'labels' } }.compact_blank.flatten
      new_labels_to_demand = labels_field.map { |label_field| label_field['toString']&.split(' ') }
      demand.update(demand_tags: new_labels_to_demand.flatten.uniq)
    end

    def read_transitions(demand, issue_changelog, demand_creator)
      backlog_transition_date = demand.created_date

      first_stage_in_the_flow = demand.first_stage_in_the_flow
      return if first_stage_in_the_flow.blank?

      first_transitions = demand.demand_transitions.where(last_time_in: backlog_transition_date)

      first_transitions.where.not(stage: backlog_transition_date).map(&:destroy) if first_transitions.count > 1

      from_transition = create_from_transition(demand, first_stage_in_the_flow.integration_id, backlog_transition_date)
      from_transition&.update(team_member: demand_creator)

      read_transition_history(demand, issue_changelog)
    rescue ActiveRecord::NotNullViolation => e
      Rails.logger.error("Invalid Demand Transition Record - Null Violation -> #{e.message}")
      nil
    end

    def read_transition_history(demand, issue_changelog)
      from_transition_date = demand.created_date

      transitions_history = sort_histories_fields(issue_changelog, 'status')
      transitions_history.each do |history|
        to_transition_date = history['created'].to_datetime
        from_transition_date = previous_transition(demand, to_transition_date)&.last_time_in || from_transition_date
        from_transition = create_from_transition(demand, history['from'], from_transition_date)
        create_to_transition(demand, from_transition, history['to'], to_transition_date, MembershipsRepository.instance.find_or_create_by_name(demand.team, history['author']['displayName'], :developer, from_transition_date).team_member)
        from_transition_date = to_transition_date
      end
    end

    def previous_transition(demand, to_transition_date)
      demand.demand_transitions.where('last_time_in < :transition_date', transition_date: to_transition_date).order(:last_time_in).last
    end

    def create_from_transition(demand, from_stage_id, transition_date)
      stage_from = demand.project.stages.find_by(integration_id: from_stage_id)
      DemandTransition.transaction { DemandTransition.where(demand: demand, stage: stage_from, last_time_in: transition_date).first_or_create }
    end

    def create_to_transition(demand, from_transistion, to_stage_id, to_transition_date, author)
      return if from_transistion.blank?

      DemandTransition.transaction do
        from_transistion.with_lock { from_transistion.update(last_time_out: to_transition_date) }

        stage_to = demand.project.stages.find_by(integration_id: to_stage_id)
        demand_transition = DemandTransition.where(demand: demand, stage: stage_to, last_time_in: to_transition_date).first_or_initialize
        demand_transition.team_member = author

        demand_transition.save

        Slack::SlackNotificationService.instance.notify_demand_state_changed(stage_to, demand, demand_transition)
      end
    rescue ArgumentError
      Rails.logger.error('Invalid Slack API - ArgumentError')
      nil
    end

    def read_comments(demand, jira_issue)
      return if jira_issue['fields']['comment'].blank?

      comments = jira_issue['fields']['comment']['comments']
      comments.each do |comment_hash|
        author_display_name = comment_hash['author']['displayName']
        membership = MembershipsRepository.instance.find_or_create_by_name(demand.team, author_display_name, :developer, comment_hash['created'])
        DemandComment.where(demand: demand, team_member: membership.team_member, comment_text: comment_hash['body'], comment_date: comment_hash['created']).first_or_create
      end
    end

    def issue_fields_value(jira_issue, field_name)
      jira_issue_attrs(jira_issue)['fields'][field_name]
    end

    def read_issue_type(company, jira_issue_attrs)
      issue_type_name = jira_issue_attrs['fields']['issuetype']['name']

      company.work_item_types.where(name: issue_type_name.capitalize).first_or_create
    end

    def read_responsibles_info(demand, jira_account, jira_issue_changelog)
      responsibles_custom_field_name = jira_account.responsibles_custom_field&.custom_field_machine_name
      return if responsibles_custom_field_name.blank?

      sort_histories_fields(jira_issue_changelog, responsibles_custom_field_name).each do |history_hash|
        next if history_hash.blank?

        responsible_hash_processment(demand, history_hash)
      end
    end

    def responsible_hash_processment(demand, history_hash)
      responsible_item_processment(demand, history_hash)

      # due to a bug when a user is deactivated in the Jira
      demand.item_assignments.open_assignments.each { |open_assignment| open_assignment.update(finish_time: open_assignment.membership.end_date.beginning_of_day) if open_assignment.membership.end_date.present? }
    end

    def responsible_item_processment(demand, history_hash)
      to_array = responsible_string_processment(history_hash['toString'])
      from_array = responsible_string_processment(history_hash['fromString'])
      unassigment_history = from_array.try(:-, to_array)

      to_array.each { |to_responsible| read_assigned_responsibles(demand, history_hash['created'].to_datetime, to_responsible.strip) } if to_array.present?
      unassigment_history.each { |from_responsible| read_unassigned_responsibles(demand, history_hash['created'].to_datetime, from_responsible.strip) } if unassigment_history.present?
    end

    def responsible_string_processment(responsible_string)
      responsible_string&.delete(']')&.delete('[')&.split(',')&.map(&:strip)
    end

    def read_unassigned_responsibles(demand, history_date, from_name)
      exiting_membership = MembershipsRepository.instance.find_or_create_by_name(demand.team, from_name, :developer, history_date)

      item_assignment_exiting = demand.item_assignments.where(membership: exiting_membership).where('start_time <= :start_time', start_time: history_date).order(:start_time).last

      item_assignment_exiting.update(finish_time: history_date) if item_assignment_exiting.present?
    end

    def read_assigned_responsibles(demand, history_date, responsible_name)
      membership = MembershipsRepository.instance.find_or_create_by_name(demand.team, responsible_name, :developer, history_date)

      ItemAssignment.transaction do
        already_assigned = demand.item_assignments.where(membership: membership, finish_time: nil)

        if already_assigned.blank?
          item_assignment = demand.item_assignments.where(membership: membership, start_time: history_date).first_or_create
          item_assignment.update(finish_time: nil)

          demand_url = company_demand_url(demand.company, demand)

          Slack::SlackNotificationService.instance.notify_item_assigned(item_assignment, demand_url)
        end
      end
    end

    def read_portfolio_unit(demand, jira_issue)
      product = demand.product
      portfolio_unit = product.portfolio_units.first

      return if portfolio_unit.blank?

      jira_portfolio_unit = jira_issue.attrs['fields'][portfolio_unit.jira_portfolio_unit_config.jira_field_name]
      return if jira_portfolio_unit.blank?

      portfolio_unit = product.portfolio_units.find_by('LOWER(name) = :name', name: jira_portfolio_unit.downcase)
      demand.update(portfolio_unit: portfolio_unit)
    end

    def jira_field_hash(histories, field_name)
      key_change_array = []
      histories.each do |history_hash|
        next if history_hash['items'].blank?

        change_key_elements = history_hash['items'].select { |item| item['field'] == field_name }
        key_change_array << change_key_elements if change_key_elements.present?
      end

      key_change_array.flatten
    end

    def hash_has_histories?(jira_issue_changelog)
      jira_issue_changelog.present? && jira_issue_changelog['histories'].present?
    end

    def process_demand_block(demand, history, history_item)
      created = history['created']

      membership = MembershipsRepository.instance.find_or_create_by_name(demand.team, history['author']['displayName'], :developer, created)

      return persist_block!(demand, membership.team_member, created) if block_history?(history_item)

      persist_unblock!(demand, membership.team_member, created) if unblock_history?(history_item)
    end

    def unblock_history?(history_item)
      history_item['fromString'].casecmp('impediment').zero? || history_item['fromString'].casecmp('impedimento').zero?
    end

    def block_history?(history_item)
      history_item['toString'].casecmp('impediment').zero? || history_item['toString'].casecmp('impedimento').zero?
    end

    def build_jira_url(jira_account, issue_key)
      "#{jira_account.base_uri}browse/#{issue_key}"
    end

    def define_customer(project, jira_account, jira_issue_attrs)
      customer_to_card = Jira::JiraReader.instance.read_customer(jira_account, jira_issue_attrs)
      return customer_to_card if customer_to_card.present?

      project.customers.first if project.customers.count == 1
    end

    def define_contract(demand, jira_account, jira_issue_changelog)
      contract_to_card = Jira::JiraReader.instance.read_contract(jira_account, jira_issue_changelog)

      if contract_to_card.present?
        demand.update(contract: contract_to_card)
      else
        active_contracts = demand.product.contracts.active(demand.date_to_use)
        demand.update(contract: active_contracts.first)
      end
    end

    def sort_histories_fields(issue_changelog, field_name)
      filtered_hash = issue_changelog['values'].map do |history|
        filter_hash_for_field(field_name, history).flatten[0]&.merge('created' => history['created'], 'author' => { 'displayName' => history['author']['displayName'] })
      end

      filtered_hash.compact_blank.sort_by { |transition| transition['created'] }
    end

    def filter_hash_for_field(field_name, history)
      history['items'].select do |item|
        item['fieldId']&.casecmp(field_name.downcase)&.zero? || item['field']&.casecmp(field_name.downcase)&.zero?
      end
    end
  end
end
