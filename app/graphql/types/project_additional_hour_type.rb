# frozen_string_literal: true

module Types
  class ProjectAdditionalHourType < Types::BaseObject
    field :event_date, GraphQL::Types::ISO8601Date, null: false
    field :hours, Float, null: false
    field :hours_type, Int, null: false
    field :id, ID, null: false
    field :obs, String, null: false
    field :project, Types::ProjectType, null: false
  end
end
