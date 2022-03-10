module TasksHelper
  def projects_for_search_options(company)
    company.projects.order(:name).map { |project| [project.name, project.id] }
  end
end
