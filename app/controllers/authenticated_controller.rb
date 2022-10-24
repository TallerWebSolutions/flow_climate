# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_company

  private

  def user_gold_check
    return true if current_user.admin?

    user_plan = current_user.current_user_plan
    return true unless user_plan.blank? || user_plan.lite? || user_plan.trial?

    no_plan_to_access(:gold)
  end

  def assign_company
    @company = Company.friendly.find(params[:company_id]&.downcase)
    not_found unless current_user.active_access_to_company?(@company)
  end

  def assign_customers
    @company_customers = @company.customers.order(name: :asc)
  end

  def assign_demand
    @demand = @company.demands.friendly.find(params[:demand_id]&.downcase)
  end

  def render_products_for_customer(render_file, customer_id)
    @products = []
    customer = Customer.find_by(id: customer_id)
    @products = customer.products.order(name: :asc) if customer.present?
    respond_to { |format| format.js { render render_file } }
  end

  def no_plan_to_access(plan_type)
    flash[:alert] = I18n.t('plans.validations.no_lite_plan')

    flash.now[:alert] = I18n.t('plans.validations.no_gold_plan') if plan_type == :gold
    redirect_to user_path(current_user)
  end

  def check_admin
    return true if current_user.admin?

    redirect_to root_path
  end

  def build_limit_date(date)
    [date, 4.weeks.ago].compact.max.to_date
  end

  def build_demands_info(demands)
    @member_finished_demands = demands.finished_with_leadtime
    statistics_service = Stats::StatisticsService.instance
    demands_leadtimes = @member_finished_demands.map(&:leadtime)
    @member_leadtime65 = statistics_service.percentile(65, demands_leadtimes) / 1.day
    @member_leadtime80 = statistics_service.percentile(80, demands_leadtimes) / 1.day
    @member_leadtime95 = statistics_service.percentile(95, demands_leadtimes) / 1.day
    @member_lead_time_histogram_data = statistics_service.leadtime_histogram_hash(demands_leadtimes)
  end
end
