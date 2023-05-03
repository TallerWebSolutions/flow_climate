# frozen_string_literal: true

module Mutations
  class CreateServiceDeliveryReviewMutation < Mutations::BaseMutation
    argument :date, GraphQL::Types::ISO8601Date, required: true
    argument :max_expedite_late, Float, required: true
    argument :max_leadtime, Float, required: false
    argument :max_quality, Float, required: true
    argument :min_expedite_late, Float, required: true
    argument :min_leadtime, Float, required: true
    argument :min_quality, Float, required: true
    argument :product_id, ID, required: true
    argument :sla, Int, required: true

    field :status_message, Types::CreateResponses, null: false

    def resolve(date:, product_id:, max_expedite_late:, max_leadtime:, max_quality:, min_expedite_late:, min_leadtime:, min_quality:, sla:)
      product = Product.find_by(id: product_id)
      params = sdr_params(date, product_id, max_expedite_late, max_leadtime, max_quality, min_expedite_late, min_leadtime, min_quality, sla, product)
      service_delivery_review = ServiceDeliveryReview.new(params.merge(product: product))

      if service_delivery_review.save
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end

    private

    def sdr_params(date, product_id, max_expedite_late, max_leadtime, max_quality, min_expedite_late, min_leadtime, min_quality, sla, product)
      {
        meeting_date: date,
        product_id: product_id,
        company_id: product[:company_id],
        delayed_expedite_top_threshold: max_expedite_late,
        lead_time_top_threshold: max_leadtime,
        quality_top_threshold: max_quality,
        delayed_expedite_bottom_threshold: min_expedite_late,
        lead_time_bottom_threshold: min_leadtime,
        quality_bottom_threshold: min_quality,
        expedite_max_pull_time_sla: sla
      }
    end
  end
end
