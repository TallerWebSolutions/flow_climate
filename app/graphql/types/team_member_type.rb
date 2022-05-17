# frozen_string_literal: true

module Types
  class TeamMemberType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :jira_account_id, String, null: true
    field :jira_account_user_email, String, null: true
    field :start_date, GraphQL::Types::ISO8601Date, null: true
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :billable, Boolean, null: false
    field :hours_per_month, Int, null: false
    field :monthly_payment, Float, null: true
    field :teams, [Types::TeamType], null: true
  end
end
