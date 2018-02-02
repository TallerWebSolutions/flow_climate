# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!

  private

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end

  def render_products_for_customer(render_file, customer_id)
    @products = []
    customer = Customer.find_by(id: customer_id)
    @products = customer.products.order(:name) if customer.present?
    respond_to { |format| format.js { render file: render_file } }
  end

  # TODO: must be removed from this class
  def add_queries_to_projects
    @projects = @projects.where(status: params[:status_filter]) if params[:status_filter] != 'all'
    @projects = @projects.order(end_date: :desc)
    @projects_summary = ProjectsSummaryObject.new(@projects)
    respond_to { |format| format.js { render file: 'projects/projects_search.js.erb' } }
  end
end
