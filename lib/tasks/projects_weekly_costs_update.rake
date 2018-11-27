# frozen_string_literal: true

namespace :projects_weekly_costs_update do
  desc 'Process projects alerts'
  task process_weekly_costs_update: :environment do
    ProjectTeamCostUpdateWeeklyJob.perform_later
  end
end
