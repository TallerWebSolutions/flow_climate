# frozen_string_literal: true

class DeviseCustomersController < ApplicationController
  before_action :authenticate_devise_customer!

  def home
    @customer = current_devise_customer.customers.first

    @customer_dashboard_data = CustomerDashboardData.new(@customer) if @customer.present?
  end
end
