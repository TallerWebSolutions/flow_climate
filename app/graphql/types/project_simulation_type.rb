# frozen_string_literal: true

module Types
  class ProjectSimulationType < Types::BaseObject
    field :team_monte_carlo_p80, Float, null: true
    field :team_monte_carlo_weeks_max, Float, null: true
    field :team_monte_carlo_weeks_min, Float, null: true
    field :team_monte_carlo_weeks_std_dev, Float, null: true
  end
end
