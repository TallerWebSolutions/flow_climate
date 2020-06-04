# frozen_string_literal: true

module Jira
  class JiraIssueAdapter < BaseFlowAdapter
    include Singleton

    def process_issue!(jira_account, product_in_jira, project, jira_issue)
      issue_key = jira_issue_attrs(jira_issue)['key']
      return if issue_key.blank?

      demand = Demand.where(company_id: project.company.id, external_id: issue_key).first_or_initialize
      project_in_jira = Jira::JiraReader.instance.read_project(jira_issue_attrs(jira_issue), jira_account) || project

      update_demand!(demand, jira_account, jira_issue, project_in_jira, product_in_jira)
      process_product_changes(jira_issue_changelog(jira_issue))
      process_labels(demand, jira_issue_changelog(jira_issue))
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
      demand.update(project: project, company: project.company, product: product, team: project.team,
                    customer: define_customer(project, jira_account, jira_issue_attrs(jira_issue)),
                    created_date: issue_fields_value(jira_issue, 'created'),
                    demand_type: read_issue_type(jira_issue_attrs(jira_issue)),
                    class_of_service: Jira::JiraReader.instance.read_class_of_service(jira_account, jira_issue_attrs(jira_issue), jira_issue_changelog(jira_issue)),
                    demand_title: issue_fields_value(jira_issue, 'summary'),
                    external_url: build_jira_url(jira_account, demand.external_id),
                    team_members: [], commitment_date: nil, discarded_at: nil)

      read_demand_details(demand, project.team, jira_account, jira_issue)
    end

    def read_demand_details(demand, team, jira_account, jira_issue)
      read_responsibles_info(demand, team, jira_account, jira_issue)
      return unless demand.valid?

      read_comments(demand, jira_issue_attrs(jira_issue))

      return unless jira_issue.respond_to?(:changelog)

      read_blocks(demand, jira_issue_changelog(jira_issue))
      read_transitions!(demand, jira_issue_changelog(jira_issue))
      demand.update(portfolio_unit: Jira::JiraReader.instance.read_portfolio_unit(jira_issue_changelog(jira_issue), jira_issue_attrs(jira_issue), demand.product)) if demand.product.present?
    end

    def read_blocks(demand, jira_issue_changelog)
      return unless hash_has_histories?(jira_issue_changelog)

      history_array = jira_issue_changelog['histories'].select(&method(:impediment_field?))

      history_array.sort_by { |history_hash| Time.zone.parse(history_hash['created']) }.each do |history|
        next if history['items'].blank?

        process_demand_block(demand, history, history['items'][0])
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
      return unless hash_has_histories?(jira_issue_changelog)

      sorted_histories = jira_issue_changelog['histories'].sort_by { |history_hash| Time.zone.parse(history_hash['created']) }
      history_array = jira_field_hash(sorted_histories, 'labels')

      history = history_array.last

      new_labels_to_demand = []

      new_labels_to_demand = history['toString']&.split(' ') if history.present?

      demand.update(demand_tags: new_labels_to_demand)
    end

    def read_transitions!(demand, issue_changelog)
      demand.demand_transitions.map(&:destroy)
      backlog_transition_date = demand.created_date

      first_stage_in_the_flow = demand.first_stage_in_the_flow
      return if first_stage_in_the_flow.blank?

      create_from_transition(demand, first_stage_in_the_flow.integration_id, backlog_transition_date)

      read_transition_history(demand, issue_changelog)
    end

    def sorted_histories(issue_changelog)
      issue_changelog['histories'].sort_by { |history_hash| history_hash['created'] }
    end

    def read_transition_history(demand, issue_changelog)
      from_transition_date = demand.created_date

      sorted_histories(issue_changelog).each do |history|
        next if history['items'].blank?

        history['items'].each do |item|
          next unless item['field'].casecmp('status').zero?

          to_transition_date = history['created']
          from_transition = create_from_transition(demand, item['from'], from_transition_date)
          create_to_transition(demand, from_transition, item['to'], to_transition_date)
          from_transition_date = to_transition_date
        end
      end
    end

    def create_from_transition(demand, from_stage_id, from_transition_date)
      ActiveRecord::Base.transaction do
        stage_from = demand.project.stages.find_by(integration_id: from_stage_id)
        demand_transition = DemandTransition.find_or_initialize_by(demand: demand, stage: stage_from, last_time_in: from_transition_date)
        demand_transition.save
        demand_transition
      end
    end

    def create_to_transition(demand, from_transistion, to_stage_id, to_transition_date)
      ActiveRecord::Base.transaction do
        from_transistion.update(last_time_out: to_transition_date)

        stage_to = demand.project.stages.find_by(integration_id: to_stage_id)
        DemandTransition.find_or_initialize_by(demand: demand, stage: stage_to, last_time_in: to_transition_date).save
      end
    end

    def read_comments(demand, jira_issue_attrs)
      return if jira_issue_attrs['fields']['comment'].blank?

      demand.demand_comments.map(&:destroy)
      comments = jira_issue_attrs['fields']['comment']['comments']
      comments.each do |comment|
        comment_author = build_author(demand.team, comment, :client)
        DemandComment.create(demand: demand, team_member: comment_author, comment_text: comment['body'], comment_date: comment['created'])
      end
    end

    def issue_fields_value(jira_issue, field_name)
      jira_issue_attrs(jira_issue)['fields'][field_name]
    end

    def read_issue_type(jira_issue_attrs)
      issue_type_name = jira_issue_attrs['fields']['issuetype']['name']
      return :bug if issue_type_name.casecmp('bug').zero?
      return :chore if issue_type_name.casecmp('chore').zero?
      return :performance_improvement if issue_type_name.casecmp('performance improvement').zero?
      return :wireframe if issue_type_name.casecmp('wireframes').zero?
      return :ui if issue_type_name.casecmp('ui').zero?

      :feature
    end

    def read_responsibles_info(demand, team, jira_account, jira_issue)
      responsibles_custom_field_name = jira_account.responsibles_custom_field&.custom_field_machine_name
      return unless responsibles_custom_field_name.present? && jira_issue.respond_to?(:changelog)

      ordered_history_data(jira_issue).each do |history_hash|
        next if history_hash['items'].blank?

        history_hash_processment(demand, history_hash, responsibles_custom_field_name, team)
      end
    end

    def history_hash_processment(demand, history_hash, responsibles_custom_field_name, team)
      history_hash['items'].each do |history_item|
        next unless history_item['fieldId'] == responsibles_custom_field_name

        history_item_processment(demand, team, history_hash, history_item)
      end
    end

    def history_item_processment(demand, team, history_hash, history_item)
      to_array = responsible_string_processment(history_item['toString'])
      from_array = responsible_string_processment(history_item['fromString'])
      unassigment_history = from_array.try(:-, to_array)

      to_array.each { |to_responsible| read_assigned_responsibles(demand, team, history_hash['created'], to_responsible.strip) } if to_array.present?
      unassigment_history.each { |from_responsible| read_unassigned_responsibles(demand, team, history_hash['created'], from_responsible.strip) } if unassigment_history.present?
    end

    def responsible_string_processment(responsible_string)
      responsible_string&.delete(']')&.delete('[')&.split(',')
    end

    def read_unassigned_responsibles(demand, team, history_date, responsible_name)
      exiting_team_member = TeamMember.where(company: team.company).where('lower(name) = :member_name', member_name: responsible_name.downcase).first

      item_assignment_exiting = ItemAssignment.where(demand: demand, team_member: exiting_team_member, finish_time: nil).first
      item_assignment_exiting.update(finish_time: history_date) if item_assignment_exiting.present?
    end

    def read_assigned_responsibles(demand, team, history_date, responsible_name)
      team_member = TeamMember.where(company: team.company).where('lower(name) = :member_name', member_name: responsible_name.downcase).first
      team_member = TeamMember.create(company: team.company, name: responsible_name.downcase) if team_member.blank?

      assignment = ItemAssignment.find_or_initialize_by(demand: demand, team_member: team_member, finish_time: nil)
      assignment.update(start_time: history_date) unless assignment.persisted?
    end

    def ordered_history_data(jira_issue)
      jira_issue.changelog['histories'].sort_by { |history| history['created'] }
    end

    def impediment_field?(history)
      return false if history['items'].blank?

      history_item = history['items'][0]
      history_item['field'].present? && (history_item['field'].casecmp('impediment').zero? || history_item['field'].casecmp('flagged').zero?)
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

      author = build_author(demand.team, history, :developer)

      return if author.blank?

      return persist_block!(demand, author, created) if block_history?(history_item)

      persist_unblock!(demand, author, created) if unblock_history?(history_item)
    end

    def unblock_history?(history_item)
      history_item['fromString'].casecmp('impediment').zero? || history_item['fromString'].casecmp('impedimento').zero?
    end

    def block_history?(history_item)
      history_item['toString'].casecmp('impediment').zero? || history_item['toString'].casecmp('impedimento').zero?
    end

    def build_author(team, history, member_role)
      author_display_name = history['author']['displayName']
      author_account_id = history['author']['accountId']

      return if author_account_id.blank? || author_display_name.blank?

      team_member = define_team_member(author_account_id, author_display_name, team)
      membership = Membership.where(team: team, team_member: team_member).first_or_initialize
      membership.update(member_role: member_role, start_date: Time.zone.today) unless membership.persisted?

      team_member.update(name: author_display_name, jira_account_id: author_account_id)
      membership.save

      team_member
    end

    def define_team_member(author_account_id, author_display_name, team)
      team_member = TeamMember.where(company: team.company).where(jira_account_id: author_account_id).first
      team_member = TeamMember.where(company: team.company).where('lower(name) LIKE :author_name', author_name: "%#{author_display_name.downcase}%").first_or_initialize if team_member.blank?
      team_member.update(start_date: Time.zone.today, name: author_display_name) unless team_member.persisted?
      team_member
    end

    def build_jira_url(jira_account, issue_key)
      "#{jira_account.base_uri}browse/#{issue_key}"
    end

    def define_customer(project, jira_account, jira_issue_attrs)
      customer_to_card = Jira::JiraReader.instance.read_customer(jira_account, jira_issue_attrs)
      return customer_to_card if customer_to_card.present?

      project.customers.first if project.customers.count == 1
    end
  end
end
