# frozen_string_literal: true

module Types
  class TeamMembersHourlyRateListType < BaseObject
      field :team_members_hourly_rate, [Types::TeamMembersHourlyRateType], null: true
  end
end