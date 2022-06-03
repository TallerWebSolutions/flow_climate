# frozen_string_literal: true

module Mutations
  class GenerateProjectCacheMutation < Mutations::BaseMutation
    argument :project_id, ID, required: true

    field :status_message, Types::BackgroundQueueResponses, null: false

    def resolve(project_id:)
      project = Project.find(project_id)

      end_date = [Time.zone.today, project.end_date.end_of_day].min

      project.remove_outdated_consolidations

      cache_date_arrays = TimeService.instance.days_between_of(project.start_date, end_date)
      cache_date_arrays.each { |cache_date| Consolidations::ProjectConsolidationJob.perform_later(project, cache_date) }
      { status_message: 'SUCCESS' }
    rescue Redis::CannotConnectError
      { status_message: 'FAIL' }
    end
  end
end
