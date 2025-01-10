# frozen_string_literal: true

module Types
  class ScoreMatrixAnswerType < Types::BaseObject
    field :answer_value, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :description, String, null: false
    field :id, ID, null: false
    field :score_matrix_question, Types::ScoreMatrixQuestionType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
