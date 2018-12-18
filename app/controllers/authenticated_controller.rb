# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!

  private

  def user_plan_check
    return true if current_user.admin?

    user_plan = current_user.current_user_plan
    return true unless user_plan.blank? || user_plan.lite? || user_plan.trial?

    no_gold_plan_to_access
  end

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

  def no_gold_plan_to_access
    flash[:alert] = I18n.t('plans.validations.no_gold_plan')
    redirect_to user_path(current_user)
  end
end
