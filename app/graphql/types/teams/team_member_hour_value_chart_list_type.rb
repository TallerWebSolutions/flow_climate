# frozen_string_literal: true

module Types
  module Teams
    class TeamMemberHourValueChartListType < Types::BaseObject
      field :member_hour_value_chart_data, [Types::Teams::MemberHourValueChartDataType]
      field :team, Types::Teams::TeamType
    end
  end
end
