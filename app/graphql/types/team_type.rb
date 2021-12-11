# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :company, Types::CompanyType, null: false
    field :team_throughput_data, [Int], null: true
    field :average_team_throughput, Float, null: true
    field :team_lead_time, Float, null: true
    field :team_wip, Int, null: true

    field :replenishing_consolidations, [Types::ReplenishingConsolidationType], null: false

    field :projects, [Types::ProjectType], null: true
    field :active_projects, [Types::ProjectType], null: true

    delegate :projects, to: :object

    def replenishing_consolidations
      team_active_projects = active_projects
      consolidations_ids = team_active_projects.map { |project| Consolidations::ReplenishingConsolidation.where(project: project).order(consolidation_date: :asc).last&.id }

      Consolidations::ReplenishingConsolidation.where(id: consolidations_ids.flatten.compact)
    end

    def team_throughput_data
      replenishing_consolidations.last&.team_throughput_data
    end

    def average_team_throughput
      replenishing_consolidations.last&.average_team_throughput
    end

    def team_lead_time
      replenishing_consolidations.last&.team_lead_time
    end

    def team_wip
      replenishing_consolidations.last&.team_wip
    end

    def active_projects
      projects.active
    end
  end
end
