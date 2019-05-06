# frozen_string_literal: true

desc 'Consolidations for flow and projects'

namespace :statistcs do
  task consolidate_weekly: :environment do
    ProjectRiskMonitorJob.perform_later
  end
end
