# frozen_string_literal: true

class MembershipsRepository
  include Singleton

  def find_or_create_by_name(team, member_name, member_role = :developer, start_date = Time.zone.today)
    team_member = TeamMember.where(company: team.company).where('lower(name) LIKE :author_name', author_name: member_name.downcase.to_s).first_or_initialize
    team_member.update(start_date: start_date, name: member_name) unless team_member.persisted?
    membership = Membership.where(team: team, team_member: team_member).first_or_initialize
    membership.update(member_role: member_role, start_date: start_date) unless membership.persisted?

    membership
  end
end
