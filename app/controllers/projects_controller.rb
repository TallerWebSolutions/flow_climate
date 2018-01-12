# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_customer
  before_action :assign_project

  def show; end

  private

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end

  def assign_customer
    @customer = Customer.find(params[:customer_id])
  end

  def assign_project
    @project = Project.find(params[:id])
  end
end
