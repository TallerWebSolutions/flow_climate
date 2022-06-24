# frozen_string_literal: true

module Types
  module Charts
    class SimpleDateChartDataType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true, hash_key: :x_axis
      field :y_axis, [Float], null: true, hash_key: :y_axis
    end
  end
end
