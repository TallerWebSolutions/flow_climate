# frozen_string_literal: true

require 'jira-ruby'

module Jira
  class JiraApiService
    attr_reader :connection_parameters

    def initialize(username, api_token, base_uri)
      @connection_parameters = { username: username, password: api_token, site: base_uri, context_path: '/', auth_type: :basic }
    end

    def request_issue(issue_key)
      client.Issue.find(issue_key)
    rescue JIRA::HTTPError => e
      if e.message.include?('Unauthorized')
        Rails.logger.error("JIRA AUTH ERROR: Credenciais inválidas ou token expirado para issue #{issue_key}. Por favor, renove o token de API do Jira para o usuário #{@connection_parameters[:username]}.")
      else
        Rails.logger.error("JIRA HTTP ERROR: #{e.message} for issue #{issue_key}")
      end
      client.Issue.build
    end

    def request_issue_changelog(issue_key, start_at = 0, max_results = 100)
      response = client.get("/rest/api/3/issue/#{issue_key}/changelog?maxResults=#{max_results}&startAt=#{start_at}")

      JSON.parse(response.body)
    rescue JIRA::HTTPError
      client.Issue.build
    end

    def request_issues_by_fix_version(project_key, release_name)
      issues = client.Issue.jql("labels IN ('#{release_name}') AND project = '#{project_key}'")
      issues = request_by_fix_version(project_key, release_name) if issues.blank?
      issues
    rescue JIRA::HTTPError
      request_by_fix_version(project_key, release_name)
    end

    def request_project(project_key)
      client.Project.find(project_key)
    rescue JIRA::HTTPError
      client.Project.build
    end

    def request_status
      client.Status.all
    rescue JIRA::HTTPError
      []
    end

    private

    def request_by_fix_version(project_key, release_name)
      client.Issue.jql("fixVersion = '#{release_name}' AND project = '#{project_key}'")
    rescue JIRA::HTTPError
      []
    end

    def client
      @client ||= JIRA::Client.new(@connection_parameters)
    end
  end
end
