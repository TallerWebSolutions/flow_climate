# frozen_string_literal: true

module Types
  module Charts
    class CumulativeFlowChartType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
      field :y_axis, [Types::Charts::CumulativeFlowYAxisType], null: true

      def y_axis
        object.cumulative_flow_diagram_downstream
      end
    end
  end
end
