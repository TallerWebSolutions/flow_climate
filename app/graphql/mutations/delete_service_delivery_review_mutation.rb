# frozen_string_literal: true

module Mutations
  class DeleteServiceDeliveryReviewMutation < BaseMutation
    argument :sdr_id, ID, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(sdr_id:)
      service_delivery_review = ServiceDeliveryReview.find_by(id: sdr_id)

      if service_delivery_review.destroy
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
