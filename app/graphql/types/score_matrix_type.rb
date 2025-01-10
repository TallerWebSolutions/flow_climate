# frozen_string_literal: true

module Types
  class ScoreMatrixType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :id, ID, null: false
    field :product, Types::ProductType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
