# frozen_string_literal: true

module Mutations
  class CreateProductRiskReview < BaseMutation
    argument :company_id, ID, required: true
    argument :lead_time_outlier_limit, Float, required: true
    argument :meeting_date, GraphQL::Types::ISO8601Date, required: true
    argument :product_id, ID, required: true

    field :risk_review, Types::RiskReviewType, null: true
    field :status_message, Types::CreateResponses, null: false

    def resolve(company_id:, product_id:, lead_time_outlier_limit:, meeting_date:)
      risk_review = RiskReview.create(company_id: company_id, product_id: product_id, lead_time_outlier_limit: lead_time_outlier_limit, meeting_date: meeting_date)
      if risk_review.valid?
        { status_message: 'SUCCESS', risk_review: risk_review }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
