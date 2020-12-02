# frozen_string_literal: true

class DeviseCustomersController < ApplicationController
  before_action :authenticate_devise_customer!

  def home
    @customer = current_devise_customer.customers.first

    return render 'devise_customers/home' if @customer.blank?

    @company = @customer.company

    @customer_dashboard_data = CustomerDashboardData.new(customer_demands)
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(customer_demands, start_date, end_date, 'month')
    @unscored_demands = @customer.exclusives_demands.unscored_demands.order(external_id: :asc)
    @demands_blocks = @customer.exclusives_demands.unscored_demands.order(external_id: :asc)
    @flow_pressure = Stats::StatisticsService.instance.mean(@customer.projects.running.map(&:flow_pressure))
  end

  private

  def customer_demands
    @customer_demands ||= @customer.exclusives_demands.finished.order(:end_date)
  end

  def start_date
    @start_date ||= customer_demands.map(&:end_date).compact.min || Time.zone.now
  end

  def end_date
    @end_date ||= [customer_demands.map(&:end_date).compact.max, Time.zone.today].compact.min
  end
end
