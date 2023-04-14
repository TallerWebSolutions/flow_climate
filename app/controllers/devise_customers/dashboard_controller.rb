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
      start_date = Time.zone.today.beginning_of_month
      end_date = Time.zone.today.end_of_month

      @customer_last_deliveries = @customer.exclusives_demands.kept.to_end_dates(start_date, end_date).order(end_date: :desc)
      @paged_customer_last_deliveries = @customer_last_deliveries.page(page_param)
    end
  end
end
