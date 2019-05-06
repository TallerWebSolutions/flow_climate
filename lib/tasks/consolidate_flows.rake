# frozen_string_literal: true

desc 'Consolidations for flow and projects'

namespace :statistics do
  task consolidate_weekly: :environment do
    ProjectConsolidationJob.perform_later
  end
end
