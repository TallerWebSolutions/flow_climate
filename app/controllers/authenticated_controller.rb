# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!

  private

  def user_gold_check
    return true if current_user.admin?

    user_plan = current_user.current_user_plan
    return true unless user_plan.blank? || user_plan.lite? || user_plan.trial?

    no_plan_to_access(:gold)
  end

  def user_lite_check
    return true if current_user.admin?

    user_plan = current_user.current_user_plan
    return true unless user_plan.blank? || user_plan.trial?

    no_plan_to_access(:lite)
  end

  def assign_company
    @company = Company.friendly.find(params[:company_id]&.downcase)
    not_found unless current_user.companies.include?(@company)
  end

  def assign_customers
    @company_customers = @company.customers.order(name: :asc)
  end

  def render_products_for_customer(render_file, customer_id)
    @products = []
    customer = Customer.find_by(id: customer_id)
    @products = customer.products.order(name: :asc) if customer.present?
    respond_to { |format| format.js { render render_file } }
  end

  def no_plan_to_access(plan_type)
    flash[:alert] = I18n.t('plans.validations.no_lite_plan')

    flash[:alert] = I18n.t('plans.validations.no_gold_plan') if plan_type == :gold
    redirect_to user_path(current_user)
  end

  def check_admin
    return true if current_user.admin?

    redirect_to root_path
  end

  def build_limit_date(date)
    [date, 4.weeks.ago].compact.max.to_date
  end
end
