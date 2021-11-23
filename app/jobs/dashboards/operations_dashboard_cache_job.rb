# frozen_string_literal: true

module Dashboards
  class OperationsDashboardCacheJob < ApplicationJob
    queue_as :dashboards

    def perform(team_member, start_date, end_date)
      array_of_dates = TimeService.instance.days_between_of(start_date, end_date)

      array_of_dates.each do |cache_date|
        demands = team_member.demands.kept.where('demands.created_date <= :date', date: cache_date)
        finished_demands = demands.where('demands.end_date <= :date', date: cache_date).order(:end_date)

        start_date_charts = [start_date, demands.map(&:end_date).flatten.compact.min].compact.max

        operations_dashboard_cache = OperationsDashboard.where(dashboard_date: cache_date, team_member: team_member).first_or_initialize

        member_effort_and_pull = build_member_effort_chart(team_member, cache_date)

        operations_dashboard_cache.update!(team_member: team_member,
                                          last_data_in_week: (cache_date.to_date) == (cache_date.to_date.end_of_week),
                                          last_data_in_month: (cache_date.to_date) == (cache_date.to_date.end_of_month),
                                          last_data_in_year: (cache_date.to_date) == (cache_date.to_date.end_of_year),
                                          first_delivery_id: finished_demands.first&.id,
                                          delivered_demands_count: finished_demands.count,
                                          demands_ids: demands.map(&:id),
                                          bugs_count: demands.bug.count,
                                          lead_time_max: team_member.lead_time_max&.leadtime.to_f,
                                          lead_time_min: team_member.lead_time_min&.leadtime.to_f,
                                          lead_time_p80: Stats::StatisticsService.instance.percentile(80, finished_demands.finished_with_leadtime&.map(&:leadtime)).to_f,
                                          projects_count: team_member.projects.count,
                                          member_effort: member_effort_and_pull[:member_effort],
                                          pull_interval: member_effort_and_pull[:team_member_pull_interval_average])

        team_member.pairing_members(cache_date).each do |membership_pair, qty_pairings|
          operations_dashboard_pairing_cache = OperationsDashboardPairing.where(pair: membership_pair.team_member, operations_dashboard: operations_dashboard_cache).first_or_initialize
          operations_dashboard_pairing_cache.update(pair_times: qty_pairings)
        end
      end

    end

    private

    def build_member_effort_chart(team_member, cache_date)
      membership_effort = []
      membership_pull_interval_average = []

      team_member.memberships.active.each do |membership|
        membership_service = Flow::MembershipFlowInformation.new(membership)

        membership_effort << membership_service.compute_developer_effort(cache_date)
        membership_pull_interval_average << membership_service.average_pull_interval(cache_date)
      end

      team_member_effort = membership_effort.compact.sum
      team_member_pull_interval_average = 0
      team_member_pull_interval_average = (membership_pull_interval_average.flatten.compact.sum / membership_pull_interval_average.flatten.count) if membership_pull_interval_average.flatten.count.positive?

      { member_effort: team_member_effort, team_member_pull_interval_average: team_member_pull_interval_average }
    end
  end
end
