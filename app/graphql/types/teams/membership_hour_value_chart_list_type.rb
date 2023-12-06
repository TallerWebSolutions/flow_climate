# frozen_string_literal: true

module Types
  module Teams
    class MembershipHourValueChartListType < Types::BaseObject
      field :membership, Types::Teams::MembershipType
      field :membership_hour_value_chart_data, [Types::Teams::MembershipHourValueChartDataType]
    end
  end
end
