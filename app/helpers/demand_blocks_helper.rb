module DemandBlocksHelper
  def team_members_options(team, selected_value)
    options_for_select(team.team_members.map{ |member| [member.name, member.name] }, selected_value)
  end
end
