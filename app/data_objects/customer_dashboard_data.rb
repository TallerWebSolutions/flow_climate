# frozen_string_literal: true

class CustomerDashboardData
  attr_reader :array_of_dates, :lead_time_accumulated, :throughput_data, :hours_delivered_upstream, :hours_delivered_downstream

  def initialize(customer)
    customer_demands = customer.demands.finished.order(:end_date)

    @array_of_dates = TimeService.instance.months_between_of(customer_demands.map(&:end_date).compact.min, end_date(customer_demands))

    statistics_information = Flow::StatisticsFlowInformations.new(customer_demands)
    time_flow_information = Flow::TimeFlowInformations.new(customer_demands)

    build_flow_services(customer_demands, statistics_information, time_flow_information)

    @lead_time_accumulated = statistics_information.lead_time_accumulated
    @hours_delivered_upstream = time_flow_information.hours_delivered_upstream
    @hours_delivered_upstream = time_flow_information.hours_delivered_downstream
  end

  private

  attr_reader :statistics_information, :time_flow_information

  def build_flow_services(customer_demands, statistics_information, time_flow_information)
    @throughput_data = []
    array_of_dates.each do |analysed_date|
      statistics_information.statistics_flow_behaviour(analysed_date)
      @throughput_data << customer_demands.to_end_dates(analysed_date.beginning_of_month, analysed_date.end_of_month).count
      time_flow_information.hours_flow_behaviour(analysed_date)
    end
  end

  def end_date(customer_demands)
    @end_date ||= [Time.zone.today.end_of_month, customer_demands.map(&:end_date).compact.max].compact.min
  end
end
