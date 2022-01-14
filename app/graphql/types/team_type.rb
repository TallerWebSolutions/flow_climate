# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :company, Types::CompanyType, null: false

    field :throughput_data, [Int], null: true

    field :average_throughput, Float, null: true
    field :increased_avg_throughtput, Boolean, null: true

    field :lead_time, Float, null: true
    field :increased_leadtime_80, Boolean, null: true

    field :work_in_progress, Int, null: true

    field :last_replenishing_consolidations, [Types::ReplenishingConsolidationType], null: false

    field :projects, [Types::ProjectType], null: true
    field :active_projects, [Types::ProjectType], null: true

    delegate :projects, to: :object

    def last_replenishing_consolidations
      team_active_projects = active_projects
      consolidations_ids = team_active_projects.map { |project| Consolidations::ReplenishingConsolidation.where(project: project).order(consolidation_date: :asc).last(1).map(&:id).flatten }

      Consolidations::ReplenishingConsolidation.where(id: consolidations_ids.flatten.compact)
    end

    def throughput_data
      last_replenishing_consolidations.last&.team_throughput_data
    end

    def average_throughput
      last_replenishing_consolidations.last&.average_team_throughput
    end

    def increased_avg_throughtput
      last_replenishing_consolidations.last&.increased_avg_throughtput?
    end

    def lead_time
      last_replenishing_consolidations.last&.team_lead_time
    end

    def increased_leadtime_80
      last_replenishing_consolidations.last&.increased_leadtime_80?
    end

    def work_in_progress
      last_replenishing_consolidations.last&.team_wip
    end

    def active_projects
      projects.active
    end
  end
end
