# frozen_string_literal: true

module Types
  class DemandType < Types::BaseObject
    field :id, ID, null: false
    field :demand_title, String, null: false
    field :team, Types::TeamType, null: false
    field :project, Types::ProjectType, null: false
  end
end
