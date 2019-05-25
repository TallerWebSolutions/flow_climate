# frozen_string_literal: true

class WebhookIntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_request

  def jira_webhook
    data = JSON.parse(request.body.read)

    jira_account_domain = extract_account_domain(project_url(data))
    jira_account = define_jira_account(jira_account_domain)
    return head :ok if jira_account.blank?

    project = define_project(data, jira_account)
    return head :ok if project.blank?

    Jira::ProcessJiraIssueJob.perform_later(jira_account, project, read_demand_key(data), nil, nil, nil)
    head :ok
  end

  def jira_delete_card_webhook
    data = JSON.parse(request.body.read)

    jira_account_domain = extract_account_domain(project_url(data))
    jira_account = define_jira_account(jira_account_domain)
    return head :ok if jira_account.blank?

    project = define_project(data, jira_account)
    return head :ok if project.blank?

    demand = Demand.find_by(project: project, demand_id: read_demand_key(data))
    demand.discard if demand.present?
    head :ok
  end

  private

  def read_demand_key(data)
    data['issue']['key']
  end

  def check_request
    head :bad_request unless valid_content_type?
  end

  def define_jira_account(jira_account_domain)
    Jira::JiraAccount.find_by(customer_domain: jira_account_domain)
  end

  def define_project(data, jira_account)
    labels = read_project_name(data)

    jira_config = nil

    company = Jira::JiraAccount.where(customer_domain: jira_account.customer_domain)&.first&.company
    return nil if company.blank?

    labels.each do |label|
      jira_config = company.project_jira_configs.find_by(jira_project_key: project_jira_key(data), fix_version_name: label)
      break if jira_config.present?
    end

    return if jira_config.blank?

    jira_config.project
  end

  def read_project_name(data)
    labels = data['issue']['fields']['labels'] || []
    fix_version_name = fix_version_name(data)

    labels << fix_version_name
    labels.reject(&:empty?)
  end

  def valid_content_type?
    request.headers['Content-Type'].include?('application/json')
  end

  def fix_version_name(data)
    return '' if data['issue']['fields']['fixVersions'].blank?

    data['issue']['fields']['fixVersions'][0]['name']
  end

  def project_jira_key(data)
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
