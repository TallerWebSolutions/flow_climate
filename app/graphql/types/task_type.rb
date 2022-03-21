# frozen_string_literal: true

module Types
  class TaskType < Types::BaseObject
    field :id, ID, null: false
    field :team, Types::TeamType, null: false
    field :initiative, Types::InitiativeType, null: false
    field :project, Types::ProjectType, null: false
    field :demand, Types::DemandType, null: false
    field :title, String, null: false
    field :created_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :completion_time, Float, null: true
  end
end
