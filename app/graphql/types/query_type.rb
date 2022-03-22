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

    field :tasks_connection,
          Types::TaskType.connection_type,
          null: true,
          description: 'A list of tasks using the arguments as search parameters' do
      argument :title, String, required: false
      argument :status, String, required: false
      argument :initiative_id, ID, required: false
      argument :project_id, ID, required: false
      argument :team_id, ID, required: false
      argument :from_date, GraphQL::Types::ISO8601Date, required: false
      argument :until_date, GraphQL::Types::ISO8601Date, required: false
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
      me.last_company.teams.preload(:company) if me.last_company.present?
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

    def tasks_connection(title: nil, status: nil, initiative_id: nil, project_id: nil, team_id: nil, from_date: nil, until_date: nil)
      return [] if me.last_company.blank?

      tasks = TasksRepository.instance.search(me.last_company_id,
                                              title: title, status: status, initiative_id: initiative_id,
                                              project_id: project_id, team_id: team_id, from_date: from_date, until_date: until_date)

      tasks.order(created_date: :desc)
    end

    def me
      context[:current_user]
    end
  end
end
