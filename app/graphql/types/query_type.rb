# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :teams,
          [Types::TeamType],
          null: true,
          description: 'Set of teams'

    field :team,
          Types::TeamType,
          null: true,
          description: 'A team with consolidations' do
      argument :id, Int
    end

    field :project,
          Types::ProjectType,
          null: true,
          description: 'A plain project' do
      argument :id, Int
    end

    field :project_consolidations,
          [Types::ProjectConsolidationType],
          null: true,
          description: 'Project consolidations' do
      argument :project_id, Int
      argument :last_data_in_week, Boolean, required: false
    end

    field :me, Types::UserType, null: false

    def teams
      Team.preload(:company)
    end

    def team(id:)
      Team.find(id)
    end

    def project_consolidations(project_id:, last_data_in_week: false)
      Consolidations::ProjectConsolidation.where(project_id: project_id, last_data_in_week: last_data_in_week).order(:consolidation_date)
    end

    def project(id:)
      Project.find(id)
    end

    def me
      context[:current_user]
    end
  end
end
