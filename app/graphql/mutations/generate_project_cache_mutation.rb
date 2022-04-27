# frozen_string_literal: true

module Mutations
  class GenerateProjectCacheMutation < Mutations::BaseMutation
    argument :project_id, String, required: true

    field :status_message, Types::BackgroundQueueResponses, null: false

    def resolve(project_id:)
      project = Project.find(project_id)
      Consolidations::ProjectConsolidationJob.perform_later(project)
      { status_message: 'SUCCESS' }
    rescue Redis::CannotConnectError
      { status_message: 'FAIL' }
    end
  end
end
