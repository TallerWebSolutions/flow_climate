# frozen_string_literal: true

module Types
  module Charts
    class CumulativeFlowChartType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
      field :y_axis, [Types::Charts::CumulativeFlowYAxisType], null: true
    end
  end
end
