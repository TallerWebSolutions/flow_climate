# frozen_string_literal: true

module Jira
  class JiraIssueAdapter < BaseFlowAdapter
    include Singleton

    def process_issue!(jira_account, product_in_jira, project, jira_issue)
      issue_key = jira_issue_attrs(jira_issue)['key']
      return if issue_key.blank?

      demand = Demand.where(company_id: project.company.id, demand_id: issue_key).first_or_initialize
      project_in_jira = Jira::JiraReader.instance.read_project(jira_issue_attrs(jira_issue), jira_account) || project

      update_demand!(demand, jira_account, jira_issue, project_in_jira, product_in_jira)
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
      demand.update(project: project, company: project.company, product: product, team: project.team, created_date: issue_fields_value(jira_issue, 'created'),
                    demand_type: read_issue_type(jira_issue_attrs(jira_issue)), artifact_type: Jira::JiraReader.instance.read_artifact_type(jira_issue_attrs(jira_issue)),
                    class_of_service: Jira::JiraReader.instance.read_class_of_service(jira_account, jira_issue_attrs(jira_issue), jira_issue_changelog(jira_issue)), demand_title: issue_fields_value(jira_issue, 'summary'),
                    url: build_jira_url(jira_account, demand.demand_id),
                    team_members: [], commitment_date: nil, discarded_at: nil)

      read_demand_details(demand, project.team, jira_account, jira_issue, project)
    end

    def read_demand_details(demand, team, jira_account, jira_issue, project)
      read_responsibles_info(demand, team, jira_account, jira_issue, project)
      return unless demand.valid?

      read_comments(demand, jira_issue_attrs(jira_issue))

      return unless jira_issue.respond_to?(:changelog)

      read_blocks(demand, jira_issue_changelog(jira_issue))
      read_transitions!(demand, jira_issue_changelog(jira_issue), jira_issue_attrs(jira_issue))
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

    def read_transitions!(demand, issue_changelog, jira_issue_attrs)
      demand.demand_transitions.map(&:destroy)
      last_time_out = demand.created_date
      read_transition_history(demand, issue_changelog)
      create_transitions!(demand, read_status_id(jira_issue_attrs), read_status_id(jira_issue_attrs), last_time_out, last_time_out) if demand.demand_transitions.blank? && jira_issue_attrs['fields']['status'].present?
    end

    def read_status_id(jira_issue_attrs)
      jira_issue_attrs['fields']['status']['id']
    end

    def sorted_histories(issue_changelog)
      issue_changelog['histories'].sort_by { |history_hash| history_hash['id'] }
    end

    def read_transition_history(demand, issue_changelog)
      last_time_out = demand.created_date

      sorted_histories(issue_changelog).each do |history|
        next if history['items'].blank?

        history['items'].each do |item|
          next unless item['field'].casecmp('status').zero?

          transition_created_at = history['created']
          create_transitions!(demand, item['from'], item['to'], last_time_out, transition_created_at)
          last_time_out = transition_created_at
        end
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

    def read_responsibles_info(demand, team, jira_account, jira_issue, _project)
      responsibles_custom_field_name = jira_account.responsibles_custom_field&.custom_field_machine_name
      return unless responsibles_custom_field_name.present? && jira_issue.respond_to?(:changelog)

      responsibles_history_hash = ordered_responsibles_data(jira_issue, responsibles_custom_field_name)

      responsibles_history_hash.each do |responsible_history|
        assigned_responsibles = read_responsibles_array(responsible_history, 'toString')

        read_assigned_responsibles(demand, team, responsible_history, assigned_responsibles)

        unassigned_responsibles = read_responsibles_array(responsible_history, 'fromString')
        next if unassigned_responsibles.blank?

        unassigned_responsibles -= assigned_responsibles

        read_unassigned_responsibles(demand, team, responsible_history, unassigned_responsibles)
      end
    end

    def read_responsibles_array(responsible_history, field)
      return [] if responsible_history['items'][0][field].blank?

      responsible_history['items'][0][field].delete(']').delete('[').split(',').map(&:strip)
    end

    def read_unassigned_responsibles(demand, team, responsible_history, unassigned_responsibles)
      unassigned_responsibles.each do |unassgined_responsible|
        exiting_team_member = TeamMember.where(company: team.company).where('lower(name) = :member_name', member_name: unassgined_responsible.downcase).first
        next if exiting_team_member.blank?

        item_assignment_exiting = ItemAssignment.where(demand: demand, team_member: exiting_team_member, finish_time: nil).first
        item_assignment_exiting.update(finish_time: responsible_history['created'])
      end
    end

    def read_assigned_responsibles(demand, team, responsible_history, assigned_responsibles)
      assigned_responsibles.each do |responsible|
        team_member = TeamMember.where(company: team.company).where('lower(name) = :member_name', member_name: responsible.downcase).first_or_initialize
        next if team_member.blank?

        assignment = ItemAssignment.where(demand: demand, team_member: team_member, finish_time: nil).first_or_initialize
        assignment.update(start_time: responsible_history['created']) unless assignment.persisted?
      end
    end

    def ordered_responsibles_data(jira_issue, responsibles_custom_field_name)
      jira_issue.changelog['histories'].select { |history| history.try(:[], 'items').try(:[], 0).try(:[], 'fieldId') == responsibles_custom_field_name }.sort_by { |history| history['created'] }
    end

    def impediment_field?(history)
      return false if history['items'].blank?

      history_item = history['items'][0]
      history_item['field'].present? && (history_item['field'].casecmp('impediment').zero? || history_item['field'].casecmp('flagged').zero?)
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

    def create_transitions!(demand, from_id, to_id, last_time_out, transition_created_at)
      stage_from = demand.project.stages.find_by(integration_id: from_id)
      stage_to = demand.project.stages.find_by(integration_id: to_id)

      transition_from = DemandTransition.where(demand: demand, stage: stage_from).first_or_initialize
      transition_from.update(last_time_in: last_time_out, last_time_out: transition_created_at)

      transition_to = DemandTransition.where(demand: demand, stage: stage_to).first_or_initialize
      transition_to.update(demand: demand, last_time_in: transition_created_at, last_time_out: nil)
    end

    def build_jira_url(jira_account, issue_key)
      "#{jira_account.base_uri}browse/#{issue_key}"
    end
  end
end
