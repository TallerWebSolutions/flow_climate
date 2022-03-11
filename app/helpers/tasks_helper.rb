# frozen-string-literal: true

module TasksHelper
  def projects_for_search_options(company)
    company.projects.order(:name).map { |project| [project.name, project.id] }
  end

  def teams_for_search_options(company)
    company.teams.order(:name).map { |team| [team.name, team.id] }
  end
end
