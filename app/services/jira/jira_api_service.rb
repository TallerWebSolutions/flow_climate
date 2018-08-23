# frozen_string_literal: true

require 'jira-ruby'

module Jira
  class JiraApiService
    attr_reader :connection_parameters

    def initialize(jira_account)
      @connection_parameters = { username: jira_account.username, password: jira_account.password, site: jira_account.base_uri, context_path: '/', auth_type: :basic, read_timeout: 120 }
    end

    def request_issue_details(issue_key)
      client.Issue.find(issue_key, expand: 'changelog')
    rescue JIRA::HTTPError => _error
      client.Issue.build
    end

    def request_issues_by_fix_version(project_key, fix_version_name)
      client.Issue.jql("fixVersion = '#{fix_version_name}' AND project = '#{project_key}'")
    rescue JIRA::HTTPError => _error
      []
    end

    private

    def client
      @client ||= JIRA::Client.new(@connection_parameters)
    end
  end
end
