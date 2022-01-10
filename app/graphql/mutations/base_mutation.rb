# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false
  end
end
