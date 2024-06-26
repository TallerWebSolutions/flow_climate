# frozen_string_literal: true

class CustomerDashboardData
  attr_reader :array_of_dates, :hours_delivered_upstream, :hours_delivered_downstream, :total_hours_delivered,
              :total_hours_delivered_accumulated, :avg_hours_delivered_accumulated, :statistics_information, :time_flow_information

  def initialize(customer_demands)
    @array_of_dates = TimeService.instance.months_between_of(start_date(customer_demands), end_date(customer_demands))

    time_flow_information = Flow::TimeFlowInformation.new(customer_demands)

    build_flow_services(time_flow_information)

    @hours_delivered_upstream = time_flow_information.hours_delivered_upstream
    @hours_delivered_downstream = time_flow_information.hours_delivered_downstream

    sum_hours_in_streams
  end

  private

  def start_date(customer_demands)
    customer_demands.filter_map(&:end_date).min
  end

  def end_date(customer_demands)
    @end_date ||= [Time.zone.today.end_of_month, customer_demands.filter_map(&:end_date).max].compact.min
  end

  def build_flow_services(time_flow_information)
    array_of_dates.each do |analysed_date|
      time_flow_information.hours_flow_behaviour(analysed_date)
    end
  end

  def sum_hours_in_streams
    @total_hours_delivered = [@hours_delivered_upstream, @hours_delivered_downstream].transpose.map(&:sum)
    @total_hours_delivered_accumulated = @total_hours_delivered.inject([]) { |x, y| x + [(x.last || 0) + y] }

    total_hours = @total_hours_delivered_accumulated&.last || 0
    @avg_hours_delivered_accumulated = total_hours.to_f / @array_of_dates.count
  end
end
