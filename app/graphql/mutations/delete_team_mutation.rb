# frozen_string_literal: true

module Mutations
  class DeleteTeamMutation < Mutations::BaseMutation
    argument :team_id, String, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(team_id:)
      team = Team.find(team_id)

      if team.destroy
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
