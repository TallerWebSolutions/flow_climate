# frozen_string_literal: true

module Types
  class TeamMemberConsolidationListType < BaseObject
    field :team_member_consolidations, [Types::TeamMemberConsolidationType], null: true
  end
end