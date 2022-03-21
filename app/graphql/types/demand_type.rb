# frozen_string_literal: true

module Types
  class DemandType < Types::BaseObject
    field :id, ID, null: false
    field :demand_title, String, null: false
  end
end
