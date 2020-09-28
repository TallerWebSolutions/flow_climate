# frozen_string_literal: true

namespace :jira_errors do
  desc 'Process Jira integration errors'
  task process_errors: :environment do
    ProjectRiskMonitorJob.perform_later
  end
end
