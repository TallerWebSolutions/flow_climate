# frozen_string_literal: true

module Mutations
  class UpdateTeamMutation < Mutations::BaseMutation
    argument :team_id, String, required: true
    argument :name, String, required: true
    argument :max_work_in_progress, Int, required: true

    field :status_message, Types::UpdateResponses, null: false

    def resolve(team_id:, name:, max_work_in_progress:)
      team = Team.find(team_id)

      if team.update(name: name, max_work_in_progress: max_work_in_progress)
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
