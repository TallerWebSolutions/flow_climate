# frozen_string_literal: true

module Types
  module Teams
    class MembershipType < Types::BaseObject
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :effort_percentage, Float
      field :end_date, GraphQL::Types::ISO8601Date
      field :expected_hour_value, Float
      field :hours_per_month, Integer
      field :hours_worked_in_month, Float
      field :id, ID, null: false
      field :member_role, Integer, null: false
      field :member_role_description, String, null: false
      field :monthly_payment, Float
      field :realized_hour_value, Float
      field :start_date, GraphQL::Types::ISO8601Date, null: false
      field :team, Types::Teams::TeamType, null: false
      field :team_id, Integer, null: false
      field :team_member_id, Integer, null: false
      field :team_member_name, String, null: false
      field :team_member_real_payment, Float
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def team_member_real_payment
        monthly_payment = object.monthly_payment
        hours_worked = hours_worked_in_month
        hours_per_month = object.hours_per_month
      
        return 0 if hours_worked.zero? || object.monthly_payment.nil? || object.hours_per_month.nil?
      
        (monthly_payment.to_d / hours_worked.to_d) * hours_per_month.to_d
      end
      
      def hours_worked_in_month
        effort = object.effort_in_period(Time.zone.today.beginning_of_month, Time.zone.today.end_of_month)
        effort.to_i.nonzero? || 0
      end

      def member_role_description
        I18n.t("activerecord.attributes.membership.enums.member_role.#{object.member_role}")
      end
    end
  end
end
