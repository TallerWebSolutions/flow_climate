# frozen_string_literal: true

module Mutations
  class CreateProjectAdditionalHoursMutation < Mutations::BaseMutation
    argument :event_date, GraphQL::Types::ISO8601Date, required: true
    argument :hours, Float, required: true
    argument :hours_type, Int, required: true
    argument :obs, String, required: false
    argument :project_id, ID, required: true

    field :status_message, Types::CreateResponses, null: false

    def resolve(project_id:, hours_type:, event_date:, hours:, obs:)
      return { status_message: 'FAIL' } if current_user.blank?

      project = Project.find(project_id)

      additional_hours = ProjectAdditionalHour.create(project: project, event_date: event_date, hours_type: hours_type, hours: hours, obs: obs)

      if additional_hours.valid?
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
