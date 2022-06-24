# frozen_string_literal: true

module Types
  module Charts
    class CumulativeFlowYAxisType < Types::BaseObject
      field :data, [Int], null: false, method: :second
      field :name, String, null: false, method: :first
    end
  end
end
