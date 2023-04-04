# frozen_string_literal: true

module Types
  module Teams
    class MemberEfficiencyDataType < Types::BaseObject
      field :avg_hours_per_demand, Float
      field :effort_in_month, Float
      field :member_capacity_value, Int
      field :membership, Types::Teams::MembershipType
      field :realized_money_in_month, Float
    end
  end
end
