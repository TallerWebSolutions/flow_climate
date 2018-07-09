# frozen_string_literal: true

module Jira
  class JiraIssueAdapter
    include Singleton

    def process_issue!(jira_issue)
      demand_id = jira_issue.attrs[:id]
      return if demand_id.blank?

      demand = Demand.where(demand_id: demand_id).first_or_create

      project = project_in_issue(jira_issue)
      return if project.blank? || project.project_jira_config.blank?
      jira_account = project.project_jira_config.jira_account

      return if jira_account.blank?

      update_issue!(demand, jira_account, jira_issue, project)
      process_transitions!(demand, jira_issue.changelog) if jira_issue.respond_to?(:changelog)

      demand
    end

    private

    def update_issue!(demand, jira_account, jira_issue, project)
      demand.update(
        project: project,
        created_date: issue_fields(jira_issue)['created'],
        demand_type: translate_issue_type(issue_fields(jira_issue)['issuetype']['name']),
        class_of_service: translate_class_of_service(jira_account, jira_issue),
        demand_title: jira_issue.attrs['summary'],
        assignees_count: compute_assignees_count(jira_account, jira_issue)
      )
    end

    def issue_fields(jira_issue)
      jira_issue.attrs['fields']
    end

    def project_in_issue(jira_issue)
      project_id = issue_fields(jira_issue)['project']['id']
      Project.find_by(integration_id: project_id)
    end

    def translate_issue_type(issue_type_name)
      return :feature if issue_type_name.casecmp('story').zero?
      return :chore if issue_type_name.casecmp('chore').zero?
      :bug
    end

    def translate_class_of_service(jira_account, jira_issue)
      class_of_service_custom_field_name = jira_account.class_of_service_custom_field&.custom_field_machine_name
      return :standard if class_of_service_custom_field_name.blank?
      class_of_service_hash = jira_issue.attrs['fields'][class_of_service_custom_field_name]
      return :standard if class_of_service_hash.blank?

      class_of_service = class_of_service_hash['value']

      if class_of_service.casecmp('expedite').zero?
        :expedite
      elsif class_of_service.casecmp('fixed date').zero?
        :fixed_date
      elsif class_of_service.casecmp('intangible').zero?
        :intangible
      else
        :standard
      end
    end

    def compute_assignees_count(jira_account, jira_issue)
      responsibles_custom_field_name = jira_account.responsibles_custom_field&.custom_field_machine_name
      return 1 if responsibles_custom_field_name.blank?

      responsibles = jira_issue.attrs['fields'][responsibles_custom_field_name]

      responsibles.count
    end

    def process_transitions!(demand, issue_changelog)
      histories = issue_changelog['histories']
      last_time_out = demand.created_date
      histories.sort_by { |history_hash| history_hash['id'] }.each do |history|
        transition_created_at = history['created']

        stage_from = Stage.find_by(integration_id: history['from'])
        stage_to = Stage.find_by(integration_id: history['to'])

        transition_from = DemandTransition.where(demand: demand, stage: stage_from).first_or_initialize
        transition_from.update(last_time_in: last_time_out, last_time_out: transition_created_at)

        transition_to = DemandTransition.where(demand: demand, stage: stage_to).first_or_initialize
        transition_to.update(last_time_in: transition_created_at)

        last_time_out = transition_created_at
      end
    end
  end
end
