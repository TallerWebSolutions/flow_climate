# frozen_string_literal: true

module Types
  class DemandScoreMatrixType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :demand, Types::DemandType, null: false
    field :id, ID, null: false
    field :score_matrix_answer, Types::ScoreMatrixAnswerType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false
  end
end
