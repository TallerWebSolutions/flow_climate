# frozen_string_literal: true

class FlowClimateSchema < GraphQL::Schema
  max_complexity 1000
  max_depth 13

  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader
end
