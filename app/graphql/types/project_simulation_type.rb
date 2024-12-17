# frozen_string_literal: true

module Types
  class ProjectSimulationType < Types::BaseObject
    field :operational_risk, Float, null: true
    field :team_operational_risk, Float, null: true

    field :current_monte_carlo_weeks_max, Float, null: true
    field :current_monte_carlo_weeks_min, Float, null: true
    field :current_monte_carlo_weeks_std_dev, Float, null: true
    field :monte_carlo_p80, Float, null: true

    field :team_monte_carlo_p80, Float, null: true
    field :team_monte_carlo_weeks_max, Float, null: true
    field :team_monte_carlo_weeks_min, Float, null: true
    field :team_monte_carlo_weeks_std_dev, Float, null: true
  end
end
