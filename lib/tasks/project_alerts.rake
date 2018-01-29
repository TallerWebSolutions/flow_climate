# frozen_string_literal: true

namespace :project_alerts do
  desc 'Process projects alerts'
  task process_alerts: :environment do
    ProjectRiskMonitorJob.perform_later
  end
end
