# frozen_string_literal: true

module Types
  class ValueEachMemberType < Types::BaseObject
    field :hourly_value, Int, null: true
    field :hours, Float, null: true
    field :member_name, String, null: true
    field :produced_value, Float, null: true
  end
end
