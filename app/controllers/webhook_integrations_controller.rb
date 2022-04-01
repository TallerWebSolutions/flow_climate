# frozen_string_literal: true

require 'addressable/uri'

class WebhookIntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :check_request
  before_action :assigns_data
  before_action :valid_jira_call?

  def jira_webhook
    Jira::ProcessJiraIssueJob.perform_later(jira_account, project, Jira::JiraReader.instance.read_demand_key(jira_issue_attrs), nil, nil, nil)

    head :ok
  end

  def jira_delete_card_webhook
    return unless project.company.active?

    demand = Demand.find_by(project: project, external_id: Jira::JiraReader.instance.read_demand_key(jira_issue_attrs))
    demand.discard if demand.present?

    head :ok
  end

  private

  def valid_jira_call?
    return head :ok if jira_issue_attrs.blank?
    return head :ok if jira_account.blank?

    head :ok if project.blank?
  end

  def project
    @project ||= Jira::JiraReader.instance.read_project(jira_issue_attrs, jira_account)
  end

  def assigns_data
    @data = JSON.parse(request.body.read)
  end

  def jira_issue_attrs
    @jira_issue_attrs ||= @data['issue']
  end

  def check_request
    head :bad_request unless valid_content_type?
  end

  def jira_account
    return @jira_account if @jira_account.present?
    return if jira_issue_attrs.blank?

    uri_host = Addressable::URI.parse(Jira::JiraReader.instance.read_project_url(jira_issue_attrs)).host
    jira_account_domain = ActionDispatch::Http::URL.extract_subdomain(uri_host, 1)

    @jira_account = Jira::JiraAccount.find_by(customer_domain: jira_account_domain)
  end

  def valid_content_type?
    request.headers['Content-Type'].include?('application/json')
  end
end
