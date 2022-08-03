# frozen_string_literal: true

module Types
  class InitiativeType < Types::BaseObject
    field :company, Types::CompanyType, null: false
    field :current_tasks_operational_risk, Float, null: false
    field :demands_count, Int, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :id, ID, null: false
    field :name, String, null: false
    field :projects_count, Int, null: false
    field :remaining_backlog_tasks_percentage, Float, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :tasks_count, Int, null: false
    field :tasks_finished_count, Int, null: false
    field :target_quarter, Types::Enums::TargetQuarter, null: true
    field :target_year, Int, null: true

    def projects_count
      object.projects.count
    end

    def demands_count
      object.demands.count
    end

    def tasks_count
      object.tasks.kept.count
    end

    def tasks_finished_count
      object.tasks.kept.finished.count
    end
  end
end
