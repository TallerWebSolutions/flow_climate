# frozen_string_literal: true

module Mutations
  class CreateServiceDeliveryReviewActionMutation < Mutations::BaseMutation
    argument :action_type, Int, required: true
    argument :deadline, GraphQL::Types::ISO8601Date, required: true
    argument :description, String, required: true
    argument :membership_id, ID, required: true
    argument :sdr_id, ID, required: true

    field :service_delivery_review_action, Types::ServiceDeliveryReviewActionItemType
    field :status_message, Types::CreateResponses, null: false

    def resolve(action_type:, deadline:, description:, membership_id:, sdr_id:)
      service_delivery_review_action = ServiceDeliveryReviewActionItem.create(action_type: action_type,
                                                                              deadline: deadline, description: description,
                                                                              membership_id: membership_id, service_delivery_review_id: sdr_id)

      if service_delivery_review_action.save
        { status_message: 'SUCCESS', service_delivery_review_action: service_delivery_review_action }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
