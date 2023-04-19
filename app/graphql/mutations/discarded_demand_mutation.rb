# frozen_string_literal: true

module Mutations
  class DiscardedDemandMutation < Mutations::BaseMutation
    argument :demand_id, String, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(demand_id:)
      demand = Demand.find(demand_id)

      if demand.discard_with_date(Time.zone.now)
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
