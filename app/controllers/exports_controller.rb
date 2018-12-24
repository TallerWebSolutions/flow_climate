# frozen_string_literal: true

class ExportsController < AuthenticatedController
  before_action :user_lite_check, only: :send_csv_data_by_email

  def request_project_information; end

  def process_requested_information
    Jira::JiraDataToCsvJob.perform_later(params[:username], params[:password], params[:base_uri], params[:project_name],
                                         params[:jira_project_key], params[:fix_version_name], params['class_of_service_field'], current_user.id)

    redirect_success
  end

  def send_csv_data_by_email
    demand_data_processment = DemandDataProcessment.find(params[:demand_data_processment_id])
    UserNotifierMailer.jira_requested_csv(current_user, demand_data_processment.downloaded_content).deliver
    DemandDataProcessment.create(user: current_user, user_plan: current_user.current_user_plan, downloaded_content: demand_data_processment.downloaded_content, project_key: demand_data_processment.project_key)
    flash[:notice] = I18n.t('exports.demand_data_processment.email_sent')
    redirect_to user_path(current_user)
  end

  private

  def redirect_success
    flash[:notice] = I18n.t('exports.request_project_information.queued')

    redirect_to request_project_information_path(jira_demand_import_fields_params)
  end

  def jira_demand_import_fields_params
    { username: params[:username], password: params[:password], base_uri: params[:base_uri], customer_domain: params[:customer_domain],
      project_name: params[:project_name], jira_project_key: params[:jira_project_key], fix_version_name: params[:fix_version_name],
      class_of_service_field: params['class_of_service_field'] }
  end
end
