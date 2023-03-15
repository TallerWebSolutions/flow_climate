# frozen_string_literal: true

module Mutations
  class CreateProductRiskReview < BaseMutation
    include Rails.application.routes.url_helpers

    argument :company_id, ID, required: true
    argument :lead_time_outlier_limit, Float, required: true
    argument :meeting_date, GraphQL::Types::ISO8601Date, required: true
    argument :product_id, ID, required: true

    field :risk_review, Types::RiskReviewType, null: true
    field :status_message, Types::CreateResponses, null: false

    def resolve(company_id:, product_id:, lead_time_outlier_limit:, meeting_date:)
      product = Product.friendly.find_by(id: product_id)
      risk_review = RiskReview.create(company_id: company_id, product_id: product_id, lead_time_outlier_limit: lead_time_outlier_limit, meeting_date: meeting_date)
      
      risk_review_url = company_product_risk_review_path(product.company, product, risk_review) if product.present?

      if risk_review.valid?
        RiskReviewGeneratorJob.perform_later(product, risk_review, current_user.email, current_user.full_name, risk_review.id, risk_review_url)
        { status_message: 'SUCCESS', risk_review: risk_review }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
