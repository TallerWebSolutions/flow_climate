# frozen_string_literal: true

module Types
  module Charts
    class SimpleDateChartDataType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
      field :y_axis, [Float], null: true
    end
  end
end
