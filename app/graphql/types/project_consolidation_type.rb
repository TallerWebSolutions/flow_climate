# frozen_string_literal: true

module Types
  class ProjectConsolidationType < Types::BaseObject
    field :id, ID, null: false
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :project, Types::ProjectType, null: false
  end
end
