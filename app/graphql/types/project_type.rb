# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    field :id, ID, null: false
    field :company, Types::CompanyType, null: false
    field :initiative, Types::InitiativeType, null: true
    field :name, String, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :aging, Int, null: false
    field :remaining_weeks, Int, null: false
    field :total_scope, Int, null: false
    field :initial_scope, Int, null: false
    field :current_weekly_hours_ideal_burnup, [Float], null: false
    field :weekly_project_scope_hours_until_end, [Int], null: false
    field :weekly_project_scope_until_end, [Int], null: false
    field :current_weekly_scope_ideal_burnup, [Int], null: false
    field :backlog_count_for, Int, null: true
    field :remaining_backlog, Int, null: false
    field :flow_pressure, Float, null: false
    field :flow_pressure_percentage, Float, null: false
    field :qty_selected, Int, null: false
    field :qty_in_progress, Int, null: false
    field :past_weeks, Int, null: false
    field :remaining_work, Int, null: false
    field :monte_carlo_p80, Float, null: false
    field :current_monte_carlo_weeks_min, Int, null: true
    field :current_monte_carlo_weeks_max, Int, null: true
    field :current_monte_carlo_weeks_std_dev, Int, null: true
    field :current_weeks_by_little_law, Int, null: true
    field :lead_time_p65, Float, null: false
    field :lead_time_p80, Float, null: false
    field :lead_time_p95, Float, null: false
    field :work_in_progress_limit, Int, null: false
    field :weekly_throughputs, [Int], null: false
    field :mode_weekly_troughputs, Int, null: false
    field :std_dev_weekly_troughputs, Float, null: false
    field :team_monte_carlo_p80, Float, null: false
    field :team_monte_carlo_weeks_max, Float, null: false
    field :team_monte_carlo_weeks_min, Float, null: false
    field :team_monte_carlo_weeks_std_dev, Float, null: false
    field :team_based_odds_to_deadline, Float, null: false
    field :current_cost, Float, null: true
    field :total_hours_consumed, Float, null: true
    field :average_speed, Float, null: true
    field :average_demand_aging, Float, null: true
    field :average_queue_time, Float, null: true
    field :average_touch_time, Float, null: true
    field :number_of_demands, Int, null: true
    field :number_of_demands_delivered, Int, null: true
    field :number_of_downstream_demands, Int, null: true
    field :demands_finished_with_leadtime, [Types::DemandType], null: true
    field :upstream_demands, [Types::DemandType], null: true
    field :discarded_demands, [Types::DemandType], null: true
    field :unscored_demands, [Types::DemandType], null: true
    field :demand_blocks, [Types::DemandType], null: true
    field :first_deadline, GraphQL::Types::ISO8601Date, null: true
    field :days_difference_between_first_and_last_deadlines, Int, null: true
    field :deadlines_change_count, Int, null: true
    field :discovered_scope, Int, null: true
    field :total_throughput, Int, null: true
    field :percentage_remaining_work, Float, null: true
    field :failure_load, Float, null: true
    field :general_leadtime, Float, null: true
    field :percentage_standard, Float, null: true
    field :percentage_expedite, Float, null: true
    field :percentage_fixed_date, Float, null: true
    field :current_risk_to_deadline, Float, null: true
    field :remaining_days, Int, null: true
    field :current_team_based_risk, Float, null: true
    field :running, Boolean, null: true
    field :customers, [Types::CustomerType], null: true
    field :products, [Types::ProductType], null: true
    field :project_consolidations_weekly, [Types::ProjectConsolidationType], null: true
    field :project_consolidations_last_month, [Types::ProjectConsolidationType], null: true
    field :project_consolidations, [Types::ProjectConsolidationType], null: true
    field :last_project_consolidations_weekly, Types::ProjectConsolidationType, null: true
    field :hours_per_stage_chart_data, Types::Charts::HoursPerStageChartType, null: true
    field :cumulative_flow_chart_data, Types::Charts::CumulativeFlowChartType, null: true
    field :demands_flow_chart_data, Types::Charts::DemandsFlowChartDataType, null: true
    field :lead_time_histogram_data, Types::Charts::LeadTimeHistogramDataType, null: true
    field :project_members, [Types::ProjectMemberType], null: true

    delegate :remaining_backlog, to: :object
    delegate :remaining_weeks, to: :object
    delegate :flow_pressure, to: :object
    delegate :monte_carlo_p80, to: :object
    delegate :team_monte_carlo_p80, to: :object
    delegate :team_monte_carlo_weeks_max, to: :object
    delegate :team_monte_carlo_weeks_min, to: :object
    delegate :team_based_odds_to_deadline, to: :object

    def unscored_demands
      object.demands.kept.unscored_demands
    end

    def discarded_demands
      object.demands.discarded
    end

    def demands_finished_with_leadtime
      object.demands.finished_with_leadtime
    end

    def number_of_downstream_demands
      object.demands.kept.in_wip(Time.zone.now).count
    end

    def number_of_demands
      object.demands.count
    end

    def number_of_demands_delivered
      object.demands.kept.finished_until_date(Time.zone.now).count
    end

    def running
      object.running?
    end

    def qty_in_progress
      object.in_wip.count
    end

    def flow_pressure_percentage
      object.relative_flow_pressure_in_replenishing_consolidation
    end

    def qty_selected
      object.qty_selected_in_week
    end

    def lead_time_p65
      object.general_leadtime(65)
    end

    def lead_time_p80
      object.general_leadtime
    end

    def lead_time_p95
      object.general_leadtime(95)
    end

    def work_in_progress_limit
      object.max_work_in_progress
    end

    def weekly_throughputs
      object.last_weekly_throughput
    end

    def mode_weekly_troughputs
      Stats::StatisticsService.instance.mode(weekly_throughputs) || 0
    end

    def std_dev_weekly_troughputs
      Stats::StatisticsService.instance.standard_deviation(weekly_throughputs)
    end

    def deadlines_change_count
      object.project_change_deadline_histories.count
    end

    def discovered_scope
      project_summary = ProjectsSummaryData.new([object])
      project_summary.discovered_scope['discovered_after']
    end

    def current_monte_carlo_weeks_min
      return 0 if last_consolidation.blank?

      last_consolidation.monte_carlo_weeks_min
    end

    def current_monte_carlo_weeks_max
      return 0 if last_consolidation.blank?

      last_consolidation.monte_carlo_weeks_max
    end

    def current_monte_carlo_weeks_std_dev
      return 0 if last_consolidation.blank?

      last_consolidation.monte_carlo_weeks_std_dev
    end

    def current_weeks_by_little_law
      return 0 if last_consolidation.blank?

      last_consolidation.weeks_by_little_law
    end

    def current_team_based_risk
      return 0 if last_consolidation.blank?

      last_consolidation.team_based_operational_risk
    end

    def project_consolidations_weekly
      weekly_project_consolidations = object.project_consolidations.weekly_data.order(:consolidation_date)

      Consolidations::ProjectConsolidation.where(id: weekly_project_consolidations.map(&:id) + [last_consolidation&.id]).order(:consolidation_date)
    end

    def project_consolidations_last_month
      object.project_consolidations.order(:consolidation_date).select(&:last_data_for_month?)
    end

    def last_project_consolidations_weekly
      object.project_consolidations.order(:consolidation_date).weekly_data.last
    end

    def hours_per_stage_chart_data
      start_date = object.start_date
      end_date = [object.end_date, Time.zone.today].min
      Highchart::StatusReportChartsAdapter.new(object.demands, start_date, end_date, 'week').hours_per_stage
    end

    def cumulative_flow_chart_data
      start_date = object.start_date
      end_date = [object.end_date, Time.zone.today].min
      Highchart::StatusReportChartsAdapter.new(object.demands, start_date, end_date, 'week')
    end

    def demands_flow_chart_data
      start_date = object.start_date
      end_date = [object.end_date, Time.zone.today].min
      Highchart::DemandsChartsAdapter.new(object.demands.kept, start_date, end_date, 'week')
    end

    def lead_time_histogram_data
      Stats::StatisticsService.instance.leadtime_histogram_hash(demands_finished_with_leadtime.map(&:leadtime).map { |leadtime| leadtime.round(3) })
    end

    def project_members
      team_members = object.team_members
      finished_demands = object.demands.finished_until_date(Time.zone.now)

      project_members_list = []

      team_members.each do |member|
        member_demands_count = finished_demands.for_team_member(member).count
        project_member = ProjectMember.new(member, member_demands_count)
        project_members_list << project_member
      end

      project_members_list
    end

    private

    def last_consolidation
      @last_consolidation ||= object.project_consolidations.order(:consolidation_date).last
    end
  end
end
