# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation
    field :send_auth_token, mutation: Mutations::SendAuthTokenMutation
    field :me, Types::UserType, null: false

    def me
      context[:current_user]
    end
  end
end
