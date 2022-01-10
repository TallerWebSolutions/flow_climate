# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation
  end
end
