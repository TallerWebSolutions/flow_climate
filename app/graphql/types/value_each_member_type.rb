# frozen_string_literal: true

module Types
  class ValueEachMemberType < Types::BaseObject
    field :effort_in_month, Float, null: true
    field :membership, Types::MembershipType, null: true
    field :realized_money_in_month, Float, null: true
  end
end
