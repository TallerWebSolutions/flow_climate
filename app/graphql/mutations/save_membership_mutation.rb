# frozen_string_literal: true

module Mutations
  class SaveMembershipMutation < Mutations::BaseMutation
    argument :effort_percentage, Float, required: true
    argument :end_date, String, required: false
    argument :hours_per_month, Integer, required: true
    argument :member_role, Integer, required: true
    argument :membership_id, ID, required: true
    argument :start_date, String, required: true

    field :membership, Types::Teams::MembershipType
    field :message, String
    field :status_message, Types::UpdateResponses, null: false

    def resolve(membership_id:, member_role:, hours_per_month:, effort_percentage:, start_date:, end_date:)
      membership = Membership.find_by(id: membership_id)

      if membership.present?
        membership.update(member_role: member_role, hours_per_month: hours_per_month, effort_percentage: effort_percentage, start_date: start_date, end_date: end_date)
        { status_message: 'SUCCESS', membership: membership, message: 'Membership updated.' }
      else
        { status_message: 'NOT_FOUND', membership: nil, message: "Membership not found with ID ##{membership_id}" }
      end
    end
  end
end
