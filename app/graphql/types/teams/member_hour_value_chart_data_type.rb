# frozen_string_literal: true

module Types
  module Teams
    class MemberHourValueChartDataType < Types::BaseObject
      field :date, GraphQL::Types::ISO8601Date
      field :hour_value_expected, Float
      field :hour_value_realized, Float
      field :hours_per_month, Int
    end
  end
end
