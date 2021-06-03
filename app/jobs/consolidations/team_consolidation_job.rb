# frozen_string_literal: true

module Consolidations
  class TeamConsolidationJob < ApplicationJob
    queue_as :consolidations

    def perform(team, cache_date = Time.zone.today)
      return if cache_date < Date.new(2018, 1, 1)

      end_of_day = cache_date.end_of_day

      demands = team.demands.where('demands.created_date <= :analysed_date', analysed_date: end_of_day)
      demands_in_week = team.demands.where('demands.created_date BETWEEN :bottom_limit AND :upper_limit', bottom_limit: end_of_day.beginning_of_week, upper_limit: end_of_day)
      demands_in_month = team.demands.where('demands.created_date BETWEEN :bottom_limit AND :upper_limit', bottom_limit: end_of_day.beginning_of_month, upper_limit: end_of_day)
      demands_in_quarter = team.demands.where('demands.created_date BETWEEN :bottom_limit AND :upper_limit', bottom_limit: end_of_day.beginning_of_quarter, upper_limit: end_of_day)
      demands_in_semester = team.demands.where('demands.created_date BETWEEN :bottom_limit AND :upper_limit', bottom_limit: TimeService.instance.beginning_of_semester(end_of_day), upper_limit: end_of_day)
      demands_in_year = team.demands.where('demands.created_date BETWEEN :bottom_limit AND :upper_limit', bottom_limit: end_of_day.beginning_of_year, upper_limit: end_of_day)

      demands_finished = demands.finished.where('demands.end_date <= :analysed_date', analysed_date: end_of_day).order(end_date: :asc)
      demands_finished_in_week = demands.to_end_dates(cache_date.beginning_of_week, cache_date)
      demands_finished_in_month = demands.to_end_dates(cache_date.beginning_of_month, cache_date)
      demands_finished_in_quarter = demands_in_quarter.to_end_dates(cache_date.beginning_of_quarter, cache_date)
      demands_finished_in_semester = demands_in_semester.to_end_dates(TimeService.instance.beginning_of_semester(cache_date), cache_date)
      demands_finished_in_year = demands_in_year.to_end_dates(cache_date.beginning_of_year, cache_date)

      demands_lead_time = demands_finished.map(&:leadtime).flatten.compact
      demands_lead_time_in_week = demands_finished_in_week.map(&:leadtime).flatten.compact
      demands_lead_time_in_month = demands_finished_in_month.map(&:leadtime).flatten.compact
      demands_lead_time_in_quarter = demands_finished_in_quarter.map(&:leadtime).flatten.compact
      demands_lead_time_in_semester = demands_finished_in_semester.map(&:leadtime).flatten.compact
      demands_lead_time_in_year = demands_finished_in_year.map(&:leadtime).flatten.compact

      lead_time_p80 = Stats::StatisticsService.instance.percentile(80, demands_lead_time)
      lead_time_p80_in_week = Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_week)
      lead_time_p80_in_month = Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_month)
      lead_time_p80_in_quarter = Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_quarter)
      lead_time_p80_in_semester = Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_semester)
      lead_time_p80_in_year = Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_year)

      value_per_demand = 0
      value_per_demand = demands_finished.sum(&:cost_to_project) / demands_finished.count unless demands_finished.count.zero?

      value_per_demand_in_month = 0
      value_per_demand_in_month = demands_finished_in_month.sum(&:cost_to_project) / demands_finished_in_month.count unless demands_finished_in_month.count.zero?

      value_per_demand_in_quarter = 0
      value_per_demand_in_quarter = demands_finished_in_quarter.sum(&:cost_to_project) / demands_finished_in_quarter.count unless demands_finished_in_quarter.count.zero?

      value_per_demand_in_semester = 0
      value_per_demand_in_semester = demands_finished_in_semester.sum(&:cost_to_project) / demands_finished_in_semester.count unless demands_finished_in_semester.count.zero?

      value_per_demand_in_year = 0
      value_per_demand_in_year = demands_finished_in_year.sum(&:cost_to_project) / demands_finished_in_year.count unless demands_finished_in_year.count.zero?

      qty_demands_created = demands.where('created_date <= :limit_date', limit_date: end_of_day)
      qty_demands_created_in_week = demands_in_week.where('created_date <= :limit_date', limit_date: end_of_day)
      qty_demands_committed = demands.where('commitment_date <= :limit_date', limit_date: end_of_day)
      qty_demands_committed_in_week = demands_in_week.where('commitment_date <= :limit_date', limit_date: end_of_day)

      bugs_opened = demands.bug.count
      bugs_opened_in_month = demands_in_month.bug.count
      bugs_opened_in_quarter = demands_in_quarter.bug.count
      bugs_opened_in_semester = demands_in_semester.bug.count
      bugs_opened_in_year = demands_in_year.bug.count

      bugs_share = bugs_opened.to_f / demands.count
      bugs_share_in_month = bugs_opened_in_month.to_f / demands_in_month.count
      bugs_share_in_quarter = bugs_opened_in_quarter.to_f / demands_in_quarter.count
      bugs_share_in_semester = bugs_opened_in_semester.to_f / demands_in_semester.count
      bugs_share_in_year = bugs_opened_in_year.to_f / demands_in_year.count

      bugs_closed = demands_finished.bug.count
      bugs_closed_in_month = demands_finished_in_month.bug.count
      bugs_closed_in_quarter = demands_finished_in_quarter.bug.count
      bugs_closed_in_semester = demands_finished_in_semester.bug.count
      bugs_closed_in_year = demands_finished_in_year.bug.count

      hours_per_demand = DemandService.instance.hours_per_demand(demands_finished)
      hours_per_demand_in_month = DemandService.instance.hours_per_demand(demands_finished_in_month)
      hours_per_demand_in_quarter = DemandService.instance.hours_per_demand(demands_finished_in_quarter)
      hours_per_demand_in_semester = DemandService.instance.hours_per_demand(demands_finished_in_semester)
      hours_per_demand_in_year = DemandService.instance.hours_per_demand(demands_finished_in_year)

      consolidation = Consolidations::TeamConsolidation.where(team: team, consolidation_date: cache_date).first_or_initialize

      flow_efficiency = DemandService.instance.flow_efficiency(demands_finished)
      flow_efficiency_in_month = DemandService.instance.flow_efficiency(demands_finished_in_month)
      flow_efficiency_in_quarter = DemandService.instance.flow_efficiency(demands_finished_in_quarter)
      flow_efficiency_in_semester = DemandService.instance.flow_efficiency(demands_finished_in_semester)
      flow_efficiency_in_year = DemandService.instance.flow_efficiency(demands_finished_in_year)

      consolidation.update(consolidation_date: cache_date,
                           last_data_in_week: (cache_date.to_date) == (cache_date.to_date.end_of_week),
                           last_data_in_month: (cache_date.to_date) == (cache_date.to_date.end_of_month),
                           last_data_in_year: (cache_date.to_date) == (cache_date.to_date.end_of_year),
                           consumed_hours_in_month: demands_finished_in_month.sum(&:total_effort),
                           hours_per_demand: hours_per_demand,
                           hours_per_demand_in_month: hours_per_demand_in_month,
                           hours_per_demand_in_quarter: hours_per_demand_in_quarter,
                           hours_per_demand_in_semester: hours_per_demand_in_semester,
                           hours_per_demand_in_year: hours_per_demand_in_year,
                           flow_efficiency: flow_efficiency,
                           flow_efficiency_in_month: flow_efficiency_in_month,
                           flow_efficiency_in_quarter: flow_efficiency_in_quarter,
                           flow_efficiency_in_semester: flow_efficiency_in_semester,
                           flow_efficiency_in_year: flow_efficiency_in_year,
                           qty_bugs_opened: bugs_opened,
                           qty_bugs_opened_in_month: bugs_opened_in_month,
                           qty_bugs_opened_in_quarter: bugs_opened_in_quarter,
                           qty_bugs_opened_in_semester: bugs_opened_in_semester,
                           qty_bugs_opened_in_year: bugs_opened_in_year,
                           qty_bugs_closed: bugs_closed,
                           qty_bugs_closed_in_month: bugs_closed_in_month,
                           qty_bugs_closed_in_quarter: bugs_closed_in_quarter,
                           qty_bugs_closed_in_semester: bugs_closed_in_semester,
                           qty_bugs_closed_in_year: bugs_closed_in_year,
                           lead_time_p80: lead_time_p80,
                           lead_time_p80_in_week: lead_time_p80_in_week,
                           lead_time_p80_in_month: lead_time_p80_in_month,
                           lead_time_p80_in_quarter: lead_time_p80_in_quarter,
                           lead_time_p80_in_semester: lead_time_p80_in_semester,
                           lead_time_p80_in_year: lead_time_p80_in_year,
                           value_per_demand: value_per_demand,
                           value_per_demand_in_month: value_per_demand_in_month,
                           value_per_demand_in_quarter: value_per_demand_in_quarter,
                           value_per_demand_in_semester: value_per_demand_in_semester,
                           value_per_demand_in_year: value_per_demand_in_year,
                           qty_demands_created: qty_demands_created,
                           qty_demands_created_in_week: qty_demands_created_in_week,
                           qty_demands_committed: qty_demands_committed,
                           qty_demands_committed_in_week: qty_demands_committed_in_week,
                           qty_demands_finished_upstream: demands_finished.finished_in_downstream.count,
                           qty_demands_finished_upstream_in_week: demands_finished_in_week.finished_in_upstream.count,
                           qty_demands_finished_upstream_in_month: demands_finished_in_month.finished_in_upstream.count,
                           qty_demands_finished_upstream_in_quarter: demands_finished_in_quarter.finished_in_upstream.count,
                           qty_demands_finished_upstream_in_semester: demands_finished_in_semester.finished_in_upstream.count,
                           qty_demands_finished_upstream_in_year: demands_finished_in_year.finished_in_upstream.count,
                           qty_demands_finished_downstream: demands_finished.finished_in_downstream.count,
                           qty_demands_finished_downstream_in_week: demands_finished_in_week.finished_in_downstream.count,
                           qty_demands_finished_downstream_in_month: demands_finished_in_month.finished_in_downstream.count,
                           qty_demands_finished_downstream_in_quarter: demands_finished_in_quarter.finished_in_downstream.count,
                           qty_demands_finished_downstream_in_semester: demands_finished_in_semester.finished_in_downstream.count,
                           qty_demands_finished_downstream_in_year: demands_finished_in_year.finished_in_downstream.count,
                           bugs_share: bugs_share,
                           bugs_share_in_month: bugs_share_in_month,
                           bugs_share_in_quarter: bugs_share_in_quarter,
                           bugs_share_in_semester: bugs_share_in_semester,
                           bugs_share_in_year: bugs_share_in_year
      )

    end
  end
end
