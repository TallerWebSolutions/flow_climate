# frozen_string_literal: true

class ProjectMember
  attr_reader :member_name, :demands_count

  def initialize(team_member, demands_count)
    @member_name = team_member.name
    @demands_count = demands_count
  end
end
