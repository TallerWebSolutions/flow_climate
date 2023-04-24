# frozen_string_literal: true

module Mutations
  class DeleteProductRiskReview < BaseMutation
    argument :risk_review_id, ID, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(risk_review_id:)
      risk_review = RiskReview.find_by(id: risk_review_id)

      if risk_review.destroy
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
