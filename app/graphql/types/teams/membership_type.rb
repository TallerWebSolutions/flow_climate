# frozen_string_literal: true

module Types
  module Teams
    class MembershipType < Types::BaseObject
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :effort_percentage, Float
      field :end_date, GraphQL::Types::ISO8601Date
      field :expected_hour_value, Float
      field :hours_per_month, Integer
      field :id, ID, null: false
      field :member_role, Integer, null: false
      field :member_role_description, String, null: false
      field :realized_hour_value, Float
      field :start_date, GraphQL::Types::ISO8601Date, null: false
      field :team, Types::Teams::TeamType, null: false
      field :team_id, Integer, null: false
      field :team_member_id, Integer, null: false
      field :team_member_name, String, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def member_role_description
        I18n.t("activerecord.attributes.membership.enums.member_role.#{object.member_role}")
      end
    end
  end
end
