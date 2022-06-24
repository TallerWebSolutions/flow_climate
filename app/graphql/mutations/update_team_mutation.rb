# frozen_string_literal: true

module Mutations
  class UpdateTeamMutation < Mutations::BaseMutation
    argument :max_work_in_progress, Int, required: true
    argument :name, String, required: true
    argument :team_id, String, required: true

    field :company, Types::CompanyType, null: true
    field :id, Int, null: true
    field :status_message, Types::UpdateResponses, null: false

    def resolve(team_id:, name:, max_work_in_progress:)
      team = Team.find(team_id)

      if team.update(name: name, max_work_in_progress: max_work_in_progress)
        { status_message: 'SUCCESS', id: team.id, company: team.company }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
