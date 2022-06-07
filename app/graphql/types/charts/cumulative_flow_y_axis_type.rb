# frozen_string_literal: true

module Types
  module Charts
    class CumulativeFlowYAxisType < Types::BaseObject
      field :name, String, null: false
      field :data, [Int], null: false

      def name
        object.first
      end

      def data
        object.second
      end
    end
  end
end
