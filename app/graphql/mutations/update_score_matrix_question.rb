# frozen_string_literal: true

module Mutations
  class UpdateScoreMatrixQuestion < BaseMutation
    argument :id, ID, required: true

    field :score_matrix_question, Types::ScoreMatrixQuestionType, null: true

    def resolve(id:)
      {}
    end
  end
end
