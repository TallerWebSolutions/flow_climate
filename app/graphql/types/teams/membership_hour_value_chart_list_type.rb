# frozen_string_literal: true

module Types
  module Teams
    class MembershipHourValueChartListType < Types::BaseObject
      field :member_hour_value_chart_data, [Types::Teams::MemberHourValueChartDataType]
      field :membership, Types::Teams::MembershipType
    end
  end
end
