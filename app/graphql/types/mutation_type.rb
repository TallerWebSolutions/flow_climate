# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation
    field :generate_project_cache, mutation: Mutations::GenerateProjectCacheMutation
    field :send_auth_token, mutation: Mutations::SendAuthTokenMutation
    field :delete_team, mutation: Mutations::DeleteTeamMutation
    field :update_team, mutation: Mutations::UpdateTeamMutation
    field :create_team, mutation: Mutations::CreateTeamMutation
    field :create_project_additional_hours, mutation: Mutations::CreateProjectAdditionalHoursMutation
    field :update_team_member, mutation: Mutations::UpdateTeamMemberMutation
    field :me, Types::UserType, null: false

    def me
      context[:current_user]
    end
  end
end
