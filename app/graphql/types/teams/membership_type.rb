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
      field :start_date, GraphQL::Types::ISO8601Date, null: false
      field :team, Types::Teams::TeamType, null: false
      field :team_id, Integer, null: false
      field :team_member_id, Integer, null: false
      field :team_member_name, String, null: false
      field :team_members_hourly_rate_list, [Types::TeamMembersHourlyRateType], null: true
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def member_role_description
        I18n.t("activerecord.attributes.membership.enums.member_role.#{object.member_role}")
      end

      # TODO: fix logic
      def team_members_hourly_rate_list
        return unless object.monthly_payment != 0 && object.team_member.billable?

        hourly_rate = []
        (1..7).reverse_each { |date| hourly_rate << build_hour_rate(date) }
        hourly_rate
      end

      private

      def build_hour_rate(date)
        { 'hour_value_realized' => compute_hours_per_month(object.monthly_payment, object.effort_in_period(Time.zone.today.ago(date.month).beginning_of_month, Time.zone.today.ago(date.month).end_of_month)), 'period_date' => Time.zone.today.ago(date.month).end_of_month }
      end

      def compute_hours_per_month(monthly_payment, effort_in_period)
        return monthly_payment if effort_in_period.zero?

        result = monthly_payment / effort_in_period
        result.round(2)
      end
    end
  end
end
