# frozen_string_literal: true

module Mutations
  class CreateServiceDeliveryReviewMutation < Mutations::BaseMutation
    include Rails.application.routes.url_helpers

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
      return { status_message: 'FAIL' } if current_user.blank?

      product = Product.find_by(id: product_id)
      service_delivery_review = create_sdr(date, max_expedite_late, max_leadtime, max_quality, min_expedite_late, min_leadtime, min_quality, product, sla)

      if service_delivery_review.valid?
        ServiceDeliveryReviewGeneratorJob.perform_later(product,
                                                        service_delivery_review,
                                                        current_user.email_address,
                                                        current_user.full_name,
                                                        service_delivery_review.id,
                                                        service_delivery_review_url(product.company, product, service_delivery_review))
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end

    private

    def create_sdr(date, max_expedite_late, max_leadtime, max_quality, min_expedite_late, min_leadtime, min_quality, product, sla)
      ServiceDeliveryReview.create(meeting_date: date,
                                   company: product.company,
                                   delayed_expedite_top_threshold: max_expedite_late,
                                   lead_time_top_threshold: max_leadtime,
                                   quality_top_threshold: max_quality,
                                   delayed_expedite_bottom_threshold: min_expedite_late,
                                   lead_time_bottom_threshold: min_leadtime,
                                   quality_bottom_threshold: min_quality,
                                   expedite_max_pull_time_sla: sla,
                                   product: product)
    end

    def service_delivery_review_url(company, product, service_delivery_review)
      company_product_service_delivery_review_path(company, product, service_delivery_review)
    end
  end
end
