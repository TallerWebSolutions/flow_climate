# frozen_string_literal: true

module Consolidations
  class CustomerConsolidationJob < ApplicationJob
    queue_as :consolidations

    def perform(customer, cache_date = Time.zone.today)

      end_of_day = cache_date.end_of_day

      demands = customer.exclusives_demands.kept.where('demands.created_date <= :analysed_date', analysed_date: end_of_day)
      demands_finished = demands.finished.where('demands.end_date <= :analysed_date', analysed_date: end_of_day).order(end_date: :asc)
      demands_finished_in_month = demands.to_end_dates(cache_date.beginning_of_month, cache_date)
      demands_lead_time = demands_finished.map(&:leadtime).flatten.compact
      demands_lead_time_in_month = demands_finished_in_month.map(&:leadtime).flatten.compact

      lead_time_p80 = Stats::StatisticsService.instance.percentile(80, demands_lead_time)
      lead_time_p80_in_month = Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_month)

      customer_dashboard_data = CustomerDashboardData.new(demands)

      hours_per_demand = 0
      value_per_demand = 0
      unless demands_finished.count.zero?
        hours_per_demand = customer_dashboard_data.total_hours_delivered_accumulated.last / demands_finished.count if customer_dashboard_data.total_hours_delivered_accumulated.last.present?
        value_per_demand = demands_finished.sum(&:cost_to_project) / demands_finished.count
      end

      hours_per_demand_in_month = 0
      value_per_demand_in_month = 0
      unless demands_finished_in_month.count.zero?
        hours_per_demand_in_month = customer_dashboard_data.total_hours_delivered.last / demands_finished_in_month.count
        value_per_demand_in_month = demands_finished_in_month.sum(&:cost_to_project) / demands_finished_in_month.count
      end

      qty_demands_created = demands.where('created_date <= :limit_date', limit_date: end_of_day)
      qty_demands_committed = demands.where('commitment_date <= :limit_date', limit_date: end_of_day)
      qty_demands_finished = demands.where('end_date <= :limit_date', limit_date: end_of_day)

      consolidation = Consolidations::CustomerConsolidation.where(customer: customer, consolidation_date: cache_date).first_or_initialize
      consolidation.update(consolidation_date: cache_date,
                           last_data_in_week: (cache_date.to_date) == (cache_date.to_date.end_of_week),
                           last_data_in_month: (cache_date.to_date) == (cache_date.to_date.end_of_month),
                           last_data_in_year: (cache_date.to_date) == (cache_date.to_date.end_of_year),
                           average_consumed_hours_in_month: customer_dashboard_data.avg_hours_delivered_accumulated,
                           consumed_hours: customer_dashboard_data.total_hours_delivered_accumulated.last,
                           consumed_hours_in_month: customer_dashboard_data.total_hours_delivered.last,
                           flow_pressure: customer.total_flow_pressure(end_of_day),
                           hours_per_demand_in_month: hours_per_demand_in_month,
                           hours_per_demand: hours_per_demand,
                           lead_time_p80: lead_time_p80,
                           lead_time_p80_in_month: lead_time_p80_in_month,
                           value_per_demand: value_per_demand,
                           value_per_demand_in_month: value_per_demand_in_month,
                           qty_demands_created: qty_demands_created,
                           qty_demands_committed: qty_demands_committed,
                           qty_demands_finished: qty_demands_finished
      )

    end
  end
end
