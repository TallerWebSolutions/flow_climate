# frozen_string_literal: true

class ProjectTeamCostUpdateWeeklyJob < ApplicationJob
  queue_as :default

  def perform
    Project.executing.each do |executing_project|
      date_beggining_of_week = Date.commercial(Time.zone.today.cwyear, Time.zone.today.cweek, 1)
      project_weekly_cost = ProjectWeeklyCost.where(date_beggining_of_week: date_beggining_of_week, project: executing_project).first_or_create
      project_weekly_cost.update(monthly_cost_value: executing_project.current_cost)
    end
  end
end
