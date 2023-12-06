# frozen_string_literal: true

module Types
  module Teams
    class MembershipHourValueChartDataType < Types::BaseObject
      field :date, GraphQL::Types::ISO8601Date
      field :hour_value_expected, Float
      field :hour_value_realized, Float
    end
  end
end
