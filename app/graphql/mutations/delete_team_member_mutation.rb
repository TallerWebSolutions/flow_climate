module Mutations
  class DeleteTeamMemberMutation < Mutations::BaseMutation
    argument :team_member_id, ID, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(team_member_id:)
      team_member = TeamMember.find_by(id: team_member_id)

      if team_member.present?
        if team_member.destroy
          { status_message: 'SUCCESS' }
        else
          { status_message: 'FAIL' }
        end
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
