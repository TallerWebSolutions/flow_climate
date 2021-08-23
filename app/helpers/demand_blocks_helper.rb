# frozen_string_literal: true

module DemandBlocksHelper
  def team_members_options(team_members, selected_value)
    options_for_select(team_members.order(:name).map { |member| [member.name, member.id] }, selected_value)
  end

  def stage_options(stages, selected_value)
    options_for_select(stages.map { |stage| [stage.name, stage.id] }, selected_value)
  end

  def project_options(projects, selected_value)
    options_for_select(projects.order(end_date: :desc).map { |project| [project.name, project.id] }, selected_value)
  end
end
