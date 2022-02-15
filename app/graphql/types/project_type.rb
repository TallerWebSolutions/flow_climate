# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    field :id, ID, null: false
    field :company, Types::CompanyType, null: false
    field :name, String, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :aging, Int, null: false
    field :remaining_weeks, Int, null: false
    field :remaining_backlog, Int, null: false
    field :flow_pressure, Float, null: false
    field :flow_pressure_percentage, Float, null: false
    field :qty_selected, Int, null: false
    field :qty_in_progress, Int, null: false
    field :monte_carlo_p80, Float, null: false
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

    field :customers, [Types::CustomerType], null: true
    field :products, [Types::ProductType], null: true

    delegate :remaining_backlog, to: :object
    delegate :remaining_weeks, to: :object
    delegate :flow_pressure, to: :object
    delegate :monte_carlo_p80, to: :object
    delegate :team_monte_carlo_p80, to: :object
    delegate :team_monte_carlo_weeks_max, to: :object
    delegate :team_monte_carlo_weeks_min, to: :object
    delegate :team_based_odds_to_deadline, to: :object

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
  end
end
