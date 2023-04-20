# frozen_string_literal: true

module Mutations
  class DiscardDemandMutation < Mutations::BaseMutation
    argument :demand_id, String, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(demand_id:)
      demand = Demand.find_by(id: demand_id)
      { status_message: 'FAIL' } if demand.blank?

      if demand.discard
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
