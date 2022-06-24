# frozen_string_literal: true

module Mutations
  class CreateTeamMutation < Mutations::BaseMutation
    argument :max_work_in_progress, Int, required: true
    argument :name, String, required: true

    field :company, Types::CompanyType, null: true
    field :id, Int, null: true
    field :status_message, Types::CreateResponses, null: false

    def resolve(name:, max_work_in_progress:)
      return { status_message: 'FAIL' } if current_user.blank?

      team = Team.create(company_id: current_user.last_company_id, name: name, max_work_in_progress: max_work_in_progress)

      if team.valid?
        { status_message: 'SUCCESS', id: team.id, company: team.company }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
