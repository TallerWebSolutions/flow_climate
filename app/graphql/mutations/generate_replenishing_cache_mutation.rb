# frozen_string_literal: true

module Mutations
  class GenerateReplenishingCacheMutation < Mutations::BaseMutation
    argument :team_id, String, required: true

    field :status_message, Types::BackgroundQueueResponses, null: false

    def resolve(team_id:)
      Consolidations::ReplenishingConsolidationJob.perform_later(team_id)
      { status_message: 'SUCCESS' }
    rescue Redis::CannotConnectError
      { status_message: 'FAIL' }
    end
  end
end
