# frozen_string_literal: true

class TeamMembersRepository
  include Singleton

  def find_or_create_by_name(company, member_name, start_date = Time.zone.today)
    team_member = TeamMember.where(company: company).where('lower(name) LIKE :author_name', author_name: "%#{member_name.downcase}%").first_or_initialize
    team_member.update(start_date: start_date, name: author_display_name) unless team_member.persisted?
    team_member
  end
end
