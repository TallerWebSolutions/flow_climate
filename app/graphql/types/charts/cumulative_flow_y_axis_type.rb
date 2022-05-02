# frozen_string_literal: true

module Types
  module Charts
    class CumulativeFlowYAxisType < Types::BaseObject
      field :name, String, null: false
      field :data, [Int], null: false
    end
  end
end
