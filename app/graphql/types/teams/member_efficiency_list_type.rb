# frozen_string_literal: true

module Types
  module Teams
    class MemberEfficiencyListType < Types::BaseObject
      field :avg_hours_per_member, Float, null: false
      field :avg_money_per_member, Float, null: false
      field :members_efficiency, [Types::Teams::MemberEfficiencyDataType], null: false
      field :team_capacity_hours, Integer, null: false
      field :total_hours_produced, Float, null: false
      field :total_money_produced, Float, null: false
    end
  end
end
