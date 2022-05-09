# frozen_string_literal: true

module Mutations
  class CreateProjectAdditionalHoursMutation < Mutations::BaseMutation
    argument :project_id, Int, required: true
    argument :hours_type, Int, required: true
    argument :hours, Float, required: true
    argument :obs, String, required: false

    field :status_message, Types::CreateResponses, null: false

    def resolve(project_id:, hours_type:, hours:, obs:)
      return { status_message: 'FAIL' } if current_user.blank?

      project = Project.find(project_id)

      additional_hours = ProjectAdditionalHour.create(project: project, hours_type: hours_type, hours: hours, obs: obs)

      if additional_hours.valid?
        { status_message: 'SUCCESS', id: additional_hours.id, project: additional_hours.project }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
