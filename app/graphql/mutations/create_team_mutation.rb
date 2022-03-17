# frozen_string_literal: true

module Mutations
  class CreateTeamMutation < Mutations::BaseMutation
    argument :name, String, required: true
    argument :max_work_in_progress, Int, required: true

    field :status_message, Types::CreateResponses, null: false

    def resolve(name:, max_work_in_progress:)
      return { status_message: 'FAIL' } if current_user.blank?

      team = Team.create(company_id: current_user.last_company_id, name: name, max_work_in_progress: max_work_in_progress)

      if team.valid?
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
