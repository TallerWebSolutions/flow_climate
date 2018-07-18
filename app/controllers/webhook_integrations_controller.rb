# frozen_string_literal: true

class WebhookIntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def pipefy_webhook
    return head :bad_request unless valid_content_type?
    data = JSON.parse(request.body.read)
    Pipefy::ProcessPipefyCardJob.perform_later(data)
    head :ok
  end

  def jira_webhook
    return head :bad_request unless valid_content_type?
    data = JSON.parse(request.body.read)

    jira_account_domain = extract_account_domain(project_url(data))

    project = define_project(data, jira_account_domain)
    return head :ok if project.blank?

    jira_account = define_jira_account(jira_account_domain)
    return head :ok if jira_account.blank?

    Jira::ProcessJiraIssueJob.perform_later(jira_account, project, issue_key(data))
    head :ok
  end

  private

  def define_jira_account(jira_account_domain)
    Jira::JiraAccount.find_by(customer_domain: jira_account_domain)
  end

  def define_project(data, jira_account_domain)
    jira_config = Jira::ProjectJiraConfig.find_by(jira_account_domain: jira_account_domain, jira_project_key: project_key(data))
    return if jira_config.blank?
    jira_config.project
  end

  def issue_key(data)
    data['issue']['key']
  end

  def valid_content_type?
    request.headers['Content-Type'].include?('application/json')
  end

  def project_key(data)
    data['issue']['fields']['project']['key']
  end

  def project_url(data)
    data['issue']['fields']['project']['self']
  end

  def extract_account_domain(project_url)
    uri_host = Addressable::URI.parse(project_url).host
    ActionDispatch::Http::URL.extract_subdomain(uri_host, 1)
  end
end
