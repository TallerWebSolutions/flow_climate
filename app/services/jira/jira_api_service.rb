# frozen_string_literal: true

require 'jira-ruby'

module Jira
  class JiraApiService
    attr_reader :connection_parameters

    def initialize(username, password, base_uri)
      @connection_parameters = { username: username, password: password, site: base_uri, context_path: '/', auth_type: :basic, read_timeout: 120 }
    end

    def request_issue_details(issue_key)
      client.Issue.find(issue_key, expand: 'changelog')
    rescue JIRA::HTTPError
      client.Issue.build
    end

    def request_issues_by_fix_version(project_key, fix_version_name)
      issues = client.Issue.jql("labels IN ('#{fix_version_name}') AND project = '#{project_key}'")
      issues = client.Issue.jql("fixVersion = '#{fix_version_name}' AND project = '#{project_key}'") if issues.blank?

      issues
    rescue JIRA::HTTPError
      []
    end

    def request_project(project_name)
      client.Project.find(project_name)
    rescue JIRA::HTTPError
      client.Project.build
    end

    private

    def client
      @client ||= JIRA::Client.new(@connection_parameters)
    end
  end
end
