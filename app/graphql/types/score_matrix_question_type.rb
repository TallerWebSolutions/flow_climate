# frozen_string_literal: true

module Types
  class ScoreMatrixQuestionType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :description, String, null: false
    field :id, ID, null: false
    field :question_type, Integer, null: false
    field :question_weight, Integer, null: false
    field :score_matrix, Types::ScoreMatrixType, null: false
    field :score_matrix_answers, [Types::ScoreMatrixAnswerType], null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
