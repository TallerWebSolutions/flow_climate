# frozen_string_literal: true

module Types
  class TaskType < Types::BaseObject
    field :company, Types::CompanyType, null: false
    field :created_date, GraphQL::Types::ISO8601Date, null: false
    field :delivered, Boolean, null: false
    field :demand, Types::DemandType, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :external_id, ID, null: true
    field :id, ID, null: false
    field :initiative, Types::InitiativeType, null: true
    field :partial_completion_time, Float, null: true
    field :project, Types::ProjectType, null: false
    field :seconds_to_complete, Float, null: true
    field :task_type, String, null: false
    field :team, Types::TeamType, null: false
    field :title, String, null: false

    def delivered
      object.end_date.present?
    end

    def team
      object.demand.team
    end

    def company
      object.demand.company
    end

    def initiative
      object.demand.project.initiative
    end

    def project
      object.demand.project
    end
  end
end
