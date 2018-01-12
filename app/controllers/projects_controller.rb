# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, except: [:index]

  def show; end

  def index
    @projects = Project.joins(:customer).where('customers.company_id = ?', @company.id)
    @projects = @projects.where(status: params[:status_filter]) if params[:status_filter].present?
    @projects = @projects.order(:end_date)
    @total_hours = @projects.sum(&:qty_hours)
    @average_hour_value = @projects.average(:hour_value)
    @total_value = @projects.sum(&:value)
    @total_days = @projects.sum(&:total_days)
    @total_remaining_days = @projects.sum(&:remaining_days)
  end

  private

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end

  def assign_project
    @project = Project.find(params[:id])
  end
end
