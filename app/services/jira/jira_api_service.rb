# frozen_string_literal: true

require 'jira-ruby'

module Jira
  class JiraApiService
    attr_reader :connection_parameters

    def initialize(jira_account)
      @connection_parameters = { username: jira_account.username, password: jira_account.password, site: jira_account.base_uri, context_path: '/', auth_type: :basic, read_timeout: 120 }
    end

    def request_issue_details(issue_key)
      client = JIRA::Client.new(@connection_parameters)
      client.Issue.find(issue_key, expand: 'changelog')
    rescue JIRA::HTTPError => _error
      client.Issue.build
    end

    def request_project(project_key)
      client = JIRA::Client.new(@connection_parameters)
      client.Project.find(project_key)
    rescue JIRA::HTTPError => _error
      client.Project.build
    end
  end
end
