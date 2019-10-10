module ChartsHelper

  def gantt_chart_to_projects(product_name, projects)
    [{ name: product_name, data: projects.map { |project| { start: project.start_date.to_time.to_i * 1000, end: project.end_date.to_time.to_i * 1000, completed: (1 - project.percentage_remaining_backlog.round(2)), name: project.name } } }]
  end
end
