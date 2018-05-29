# frozen_string_literal: true

namespace :pipefy do
  desc 'Process projects alerts'
  task update_projects: :environment do
    Project.joins(:pipefy_config).running.each do |project|
      ProcessPipefyProjectJob.perform_later(project.id)
    end
  end
end
