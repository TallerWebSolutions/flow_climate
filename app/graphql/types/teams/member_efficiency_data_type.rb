# frozen_string_literal: true

module Types
  module Teams
    class MemberEfficiencyDataType < Types::BaseObject
      field :avg_hours_per_demand, Float
      field :cards_count, Int
      field :effort_in_month, Float
      field :hour_value_expected, Float
      field :hour_value_realized, Float
      field :member_capacity_value, Int
      field :membership, Types::Teams::MembershipType
      field :realized_money_in_month, Float
    end
  end
end
