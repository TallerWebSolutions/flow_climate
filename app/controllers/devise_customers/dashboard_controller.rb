# frozen_string_literal: true

module DeviseCustomers
  class DashboardController < ApplicationController
    before_action :authenticate_devise_customer!

    def home
      @customer = current_devise_customer.customers.last

      return not_found if @customer.blank?

      return render 'dashboard/home' if @customer.blank?

      @company = @customer.company
      @contracts = @customer.contracts

      @customer_consolidations = @customer.customer_consolidations.monthly_data.order(:consolidation_date)
      assign_last_deliveries
    end

    private

    def assign_last_deliveries
      @customer_last_deliveries = @customer.exclusives_demands.includes([:company]).includes([:project]).kept.finished_until_date(Time.zone.now).order(end_date: :desc).first(10)
    end
  end
end
