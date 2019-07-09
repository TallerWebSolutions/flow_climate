# frozen_string_literal: true

module Jira
  class JiraIssueAdapter < BaseFlowAdapter
    include Singleton

    def process_issue!(jira_account, product_in_jira, project, jira_issue)
      issue_key = jira_issue.attrs['key']
      return if issue_key.blank?

      demand = Demand.where(company_id: project.company.id, demand_id: issue_key).first_or_initialize
      project_in_jira = Jira::JiraReader.instance.read_project(jira_issue.attrs, jira_account) || project

      update_demand!(demand, jira_account, jira_issue, project_in_jira, product_in_jira)
    end

    private

    def update_demand!(demand, jira_account, jira_issue, project, product)
      demand.update(project: project, company: project.company, product: product, created_date: issue_fields_value(jira_issue, 'created'),
                    demand_type: read_issue_type(jira_issue), artifact_type: Jira::JiraReader.instance.read_artifact_type(jira_issue.attrs),
                    class_of_service: Jira::JiraReader.instance.read_class_of_service(jira_account, jira_issue.attrs), demand_title: issue_fields_value(jira_issue, 'summary'),
                    url: build_jira_url(jira_account, demand.demand_id), commitment_date: nil, discarded_at: nil)

      read_demand_details(demand, jira_account, jira_issue, project)
    end

    def read_demand_details(demand, jira_account, jira_issue, project)
      read_responsibles_info(demand, jira_account, jira_issue, project)
      return unless demand.valid?

      read_comments(demand, jira_issue)
      read_blocks(demand, jira_issue)
      return unless jira_issue.respond_to?(:changelog)

      read_transitions!(demand, jira_issue.changelog)
      demand.update(portfolio_unit: Jira::JiraReader.instance.read_portfolio_unit(jira_issue.changelog, demand.product)) if demand.product.present?
    end

    def read_blocks(demand, jira_issue)
      return unless hash_have_histories?(jira_issue)

      history_array = jira_issue.attrs['changelog']['histories'].select(&method(:impediment_field?))

      demand.demand_blocks.map(&:destroy)

      history_array.sort_by { |history_hash| Time.zone.parse(history_hash['created']) }.each do |history|
        next if history['items'].blank?

        process_demand_block(demand, history, history['items'][0])
      end
    end

    def read_transitions!(demand, issue_changelog)
      demand.demand_transitions.map(&:destroy)

      last_time_out = demand.created_date
      issue_changelog['histories'].sort_by { |history_hash| history_hash['id'] }.each do |history|
        next if history['items'].blank?

        history['items'].each do |item|
          next unless item['field'].casecmp('status').zero?

          transition_created_at = history['created']
          create_transitions!(demand, item['from'], item['to'], last_time_out, transition_created_at)
          last_time_out = transition_created_at
        end
      end
    end

    def read_comments(demand, jira_issue)
      return if jira_issue.attrs['fields']['comment'].blank?

      demand.demand_comments.map(&:destroy)
      comments = jira_issue.attrs['fields']['comment']['comments']
      comments.each do |comment|
        comment_author = TeamMember.find_by(jira_account_user_email: comment['author']['emailAddress'])
        DemandComment.create(demand: demand, team_member: comment_author, comment_text: comment['body'], comment_date: comment['created'])
      end
    end

    def issue_fields_value(jira_issue, field_name)
      jira_issue.attrs['fields'][field_name]
    end

    def read_issue_type(jira_issue)
      issue_type_name = jira_issue.attrs['fields']['issuetype']['name']
      return :bug if issue_type_name.casecmp('bug').zero?
      return :chore if issue_type_name.casecmp('chore').zero?
      return :performance_improvement if issue_type_name.casecmp('performance improvement').zero?
      return :wireframe if issue_type_name.casecmp('wireframes').zero?
      return :ui if issue_type_name.casecmp('ui').zero?

      :feature
    end

    def read_responsibles_info(demand, jira_account, jira_issue, project)
      responsibles_custom_field_name = jira_account.responsibles_custom_field&.custom_field_machine_name
      return 1 if responsibles_custom_field_name.blank?

      responsibles = jira_issue.attrs['fields'][responsibles_custom_field_name]

      return 1 if responsibles.blank?

      responsibles = TeamMember.where(jira_account_user_email: jira_issue.attrs['fields'][responsibles_custom_field_name].map { |responsible| responsible['emailAddress'] })

      demand.update(team_members: responsibles, team: define_team(project, responsibles), assignees_count: responsibles.count)
    end

    def define_team(project, responsibles)
      responsibles.first&.team || project.team
    end

    def impediment_field?(history)
      return false if history['items'].blank?

      history_item = history['items'][0]
      history_item['field'].present? && (history_item['field'].casecmp('impediment').zero? || history_item['field'].casecmp('flagged').zero?)
    end

    def hash_have_histories?(jira_issue)
      jira_issue.attrs['changelog'].present? && jira_issue.attrs['changelog']['histories'].present?
    end

    def process_demand_block(demand, history, history_item)
      created = history['created']

      author = history['author']['displayName']

      if history_item['toString'].casecmp('impediment').zero? || history_item['toString'].casecmp('impedimento').zero?
        persist_block!(demand, author, created)
      elsif history_item['fromString'].casecmp('impediment').zero? || history_item['fromString'].casecmp('impedimento').zero?
        persist_unblock!(demand, author, created)
      end
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
