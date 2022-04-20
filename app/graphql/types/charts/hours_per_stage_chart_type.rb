# frozen_string_literal: true

module Types
  module Charts
    class HoursPerStageChartType < Types::BaseObject
      field :x_axis, [String], null: true
      field :y_axis, [Int], null: true

      def y_axis
        object[:y_axis][:data]
      end
    end
  end
end
