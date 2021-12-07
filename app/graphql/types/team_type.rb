# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :wip_limit, Int, null: true
    field :company, Types::CompanyType, null: false
    field :project_consolidations, [Types::ProjectConsolidationType], null: true
    field :projects, [Types::ProjectType], null: false
    field :active_projects, [Types::ProjectType], null: false
    field :team_throughputs, [Int], null: true do
      argument :order_by, String, required: false
      argument :direction, String, required: false
      argument :limit, Int, required: false
    end

    delegate :projects, to: :object

    def wip_limit
      object.max_work_in_progress
    end

    def project_consolidations
      consolidations = []
      team_active_projects = active_projects
      team_active_projects.each { |project| consolidations << project.project_consolidations.order(:consolidation_date).last }

      consolidations
    end

    def active_projects
      projects.active
    end

    def team_throughputs(order_by: 'consolidation_date', direction: 'asc', limit: 10)
      object.team_throughputs(order_by, direction, limit)
    end
  end
end
