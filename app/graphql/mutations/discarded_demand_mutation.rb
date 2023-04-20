# frozen_string_literal: true

module Mutations
  class DiscardedDemandMutation < Mutations::BaseMutation
    argument :demand_id, String, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(demand_id:)
      demand = Demand.find(demand_id)

      demand.discard_with_date(Time.zone.now)
      { status_message: 'SUCCESS' }
    end
  end
end
