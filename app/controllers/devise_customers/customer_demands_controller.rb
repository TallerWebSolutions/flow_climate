# frozen_string_literal: true

module DeviseCustomers
  class CustomerDemandsController < ApplicationController
    before_action :authenticate_devise_customer!

    def show
      prepend_view_path Rails.public_path
      render 'spa-build/index'
    end

    def demand_efforts
      prepend_view_path Rails.public_path
      render 'spa-build/index'
    end

    def search
      @customer = current_devise_customer.customers.last

      return not_found if @customer.blank?

      @company = @customer.company
      start_date = params[:demands_start_date].to_date
      end_date = params[:demands_end_date].to_date

      @customer_last_deliveries = @customer.exclusives_demands.kept.to_end_dates(start_date, end_date).order(end_date: :desc)
      @paged_customer_last_deliveries = @customer_last_deliveries.page(page_param)
    end
  end
end
