# frozen_string_literal: true

module Types
  module Teams
    class MembershipType < Types::BaseObject
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :effort_percentage, Float
      field :end_date, GraphQL::Types::ISO8601Date
      field :hours_per_month, Integer
      field :id, ID, null: false
      field :member_role, Integer, null: false
      field :member_role_description, String, null: false
      field :start_date, GraphQL::Types::ISO8601Date, null: false
      field :team, Types::Teams::TeamType, null: false
      field :team_id, Integer, null: false
      field :team_member_id, Integer, null: false
      field :team_member_name, String, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
      field :team_members_hourly_rate_list, [Types::TeamMembersHourlyRateType], null: true

      def member_role_description
        I18n.t("activerecord.attributes.membership.enums.member_role.#{object.member_role}")
      end

      def team_members_hourly_rate_list 
        tmhrl = []
        (1..13).reverse_each do |date|
          tmhrl << {'value_per_hour_performed' => (calculate_hours_per_month(object.monthly_payment, object.effort_in_period(Date.today.ago(date.month).beginning_of_month, Date.today.ago(date.month).end_of_month))), 'period_date' => Date.today.ago(date.month).beginning_of_month  }
        end
        tmhrl
      end
      
      def calculate_hours_per_month(sallary, month_hours)
        result = sallary / (month_hours.nonzero? || 1)
        if result.infinite? || result > 2000.00
          0.0
        else
          (result.to_f).round(2)
        end
      end
    end
  end
end
