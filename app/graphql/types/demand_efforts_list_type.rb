# frozen_string_literal: true

module Types
  class DemandEffortsListType < BaseObject
    field :demand_efforts, [Types::DemandEffortType], null: true
    field :demand_efforts_count, Int, null: true
    field :efforts_value_sum, Float, null: true
  end
end
