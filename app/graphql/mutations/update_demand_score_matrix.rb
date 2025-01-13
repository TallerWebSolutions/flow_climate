# frozen_string_literal: true

module Mutations
  class UpdateDemandScoreMatrix < BaseMutation
    argument :answer_id, ID, required: true
    argument :matrix_id, ID, required: true

    field :demand_score_matrix, Types::DemandScoreMatrixType, null: true
    field :status_message, Types::UpdateResponses, null: true

    def resolve(matrix_id:, answer_id:)
      matrix = DemandScoreMatrix.find_by(id: matrix_id)
      answer = ScoreMatrixAnswer.find_by(id: answer_id)

      return { status_message: 'NOT_FOUND' } unless matrix.present? && answer.present?

      matrix.update(score_matrix_answer: answer)
      { demand_score_matrix: matrix, status_message: 'SUCCESS' }
    end
  end
end
