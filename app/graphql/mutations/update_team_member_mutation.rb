# frozen_string_literal: true

module Mutations
  class UpdateTeamMemberMutation < Mutations::BaseMutation
    argument :billable, Boolean, required: true
    argument :end_date, GraphQL::Types::ISO8601Date, required: false
    argument :hours_per_month, Int, required: true
    argument :jira_account_id, String, required: false
    argument :jira_account_user_email, String, required: false
    argument :monthly_payment, Float, required: false
    argument :name, String, required: true
    argument :start_date, GraphQL::Types::ISO8601Date, required: true
    argument :team_member_id, Int, required: true

    field :updated_team_member, Types::TeamMemberType, null: false

    def resolve(team_member_id:, name:, start_date:, end_date:, jira_account_user_email:, jira_account_id:, hours_per_month:, monthly_payment:, billable:)
      team_member = TeamMember.find(team_member_id)

      if current_user.present?
        team_member.update(name: name, start_date: start_date, end_date: end_date, jira_account_user_email: jira_account_user_email, jira_account_id: jira_account_id,
                           hours_per_month: hours_per_month, monthly_payment: monthly_payment, billable: billable)
      end

      { updated_team_member: team_member }
    end
  end
end
