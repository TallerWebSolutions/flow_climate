# frozen_string_literal: true

module Types
  # rubocop:disable Metrics/ClassLength
  class ProjectType < Types::BaseObject
    field :id, ID, null: false
    field :company, Types::CompanyType, null: false
    field :name, String, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :aging, Int, null: false
    field :remaining_weeks, Int, null: false
    field :total_scope, Int, null: false
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
    field :lead_time_p80, Float, null: false
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
    field :project_consolidations, [Types::ProjectConsolidationType], null: true

    delegate :remaining_backlog, to: :object
    delegate :remaining_weeks, to: :object
    delegate :flow_pressure, to: :object
    delegate :monte_carlo_p80, to: :object
    delegate :team_monte_carlo_p80, to: :object
    delegate :team_monte_carlo_weeks_max, to: :object
    delegate :team_monte_carlo_weeks_min, to: :object
    delegate :team_based_odds_to_deadline, to: :object

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

    def lead_time_p80
      object.general_leadtime
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
      object.project_consolidations.last.monte_carlo_weeks_min
    end

    def current_monte_carlo_weeks_max
      object.project_consolidations.last.monte_carlo_weeks_max
    end

    def current_monte_carlo_weeks_std_dev
      object.project_consolidations.last.monte_carlo_weeks_std_dev
    end

    def current_weeks_by_little_law
      object.project_consolidations.last.weeks_by_little_law
    end

    def current_team_based_risk
      object.project_consolidations.last.team_based_operational_risk
    end
  end
  # rubocop:enable Metrics/ClassLength
end
