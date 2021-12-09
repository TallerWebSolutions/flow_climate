# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :company, Types::CompanyType, null: false

    field :replenishing_consolidations, [Types::ReplenishingConsolidationType], null: true do
      argument :order_by, String, required: false
      argument :direction, String, required: false
      argument :limit, Int, required: false
    end

    field :projects, [Types::ProjectType], null: false
    field :active_projects, [Types::ProjectType], null: false

    delegate :projects, to: :object

    def replenishing_consolidations(order_by: 'consolidation_date', direction: 'asc', limit: 10)
      consolidations = []
      team_active_projects = active_projects
      team_active_projects.each { |project| consolidations << Consolidations::ReplenishingConsolidation.where(project: project).order(order_by => direction).limit(limit).last }

      consolidations
    end

    def active_projects
      projects.active
    end
  end
end
