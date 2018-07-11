# frozen_string_literal: true

class WebhookIntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def pipefy_webhook
    return head :bad_request unless invalid_content_type?
    data = JSON.parse(request.body.read)
    Pipefy::ProcessPipefyCardJob.perform_later(data)
    head :ok
  end

  def jira_webhook
    return head :bad_request unless invalid_content_type?
    data = JSON.parse(request.body.read)

    jira_account_domain = extract_account_domain(project_url(data))
    project_jira_config = Jira::ProjectJiraConfig.find_by(jira_account_domain: jira_account_domain, jira_project_key: project_key(data))
    return head :ok if project_jira_config.blank?

    jira_account = Jira::JiraAccount.find_by(customer_domain: jira_account_domain)

    Jira::ProcessJiraIssueJob.perform_later(jira_account, project_jira_config.project, data['issue'])
    head :ok
  end

  private

  def invalid_content_type?
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
