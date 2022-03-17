# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation
    field :send_auth_token, mutation: Mutations::SendAuthTokenMutation
    field :delete_team, mutation: Mutations::DeleteTeamMutation
    field :update_team, mutation: Mutations::UpdateTeamMutation
    field :create_team, mutation: Mutations::CreateTeamMutation
    field :me, Types::UserType, null: false

    def me
      context[:current_user]
    end
  end
end
