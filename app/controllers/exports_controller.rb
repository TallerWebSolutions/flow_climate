# frozen_string_literal: true

class ExportsController < AuthenticatedController
  def request_project_information; end

  def process_requested_information
    jira_api_service = Jira::JiraApiService.new(params[:username], params[:password], params[:base_uri])
    project_issues = jira_api_service.request_issues_by_fix_version(params[:jira_project_key], params[:fix_version_name])

    array_of_jira_issues_keys = []
    array_of_project_keys = []
    array_of_issue_types = []
    array_of_class_of_services = []
    array_of_created_date = []

    history_data_hash = {}
    history_fields = []

    project_issues.each do |jira_issue|
      next if jira_issue.attrs['key'].blank?

      jira_issue_with_transitions = jira_api_service.request_issue_details(jira_issue.attrs['key'])

      array_of_jira_issues_keys << jira_issue_with_transitions.attrs['key']
      array_of_project_keys << jira_issue_with_transitions.attrs['fields'].try(:[], 'project').try(:[], 'key')
      array_of_issue_types << jira_issue_with_transitions.attrs['fields'].try(:[], 'issuetype').try(:[], 'name')
      array_of_class_of_services << jira_issue_with_transitions.attrs['fields'].try(:[], class_of_service_field_name).try(:[], 'value')
      array_of_created_date << jira_issue_with_transitions.attrs['fields'].try(:[], 'created')

      next unless jira_issue_with_transitions.respond_to?(:changelog)

      issue_changelog = jira_issue_with_transitions.changelog

      history_data_hash[jira_issue.attrs['key']] = {}
      issue_changelog['histories'].sort_by { |history_hash| history_hash['id'] }.each do |history|
        next unless transition_history?(history)

        history_stage_name = history['items'].first['toString']
        transition_date = history['created'].to_time.iso8601
        new_date_value = history_data_hash[history_stage_name]&.to_time&.iso8601
        history_data_hash[jira_issue.attrs['key']][history_stage_name] = history['created'] if new_date_value.blank? || new_date_value < transition_date
      end
      history_fields.concat(history_data_hash[jira_issue.attrs['key']].keys).uniq!
    end

    basic_fields_to_csv = "jira_key,project_key,issue_type,class_of_service,created_date,#{history_fields.join(',')}\n"

    values_to_csv_fields = ''
    array_of_jira_issues_keys.each_with_index do |issue_key, index|
      values_to_csv_fields += "#{issue_key},#{array_of_project_keys[index]},#{array_of_issue_types[index]},#{array_of_class_of_services[index]},#{array_of_created_date[index]}"
      history_fields.each { |history_field| values_to_csv_fields += ",#{history_data_hash[issue_key][history_field]}" }
      values_to_csv_fields += "\n"
    end

    demands_as_csv = basic_fields_to_csv + values_to_csv_fields

    respond_to { |format| format.csv { send_data demands_as_csv, filename: "demands-#{Time.zone.now}.csv" } }
  end

  private

  def class_of_service_field_name
    params['class_of_service_field']
  end

  def transition_history?(history)
    history['items'].present? && history['items'].first['field'].casecmp('status').zero?
  end
end
