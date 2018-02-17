# frozen_string_literal: true

namespace :synchronize do
  desc 'Process projects alerts'
  task pipefy_sync: :environment do
    ProcessPipefyPipeJob.perform_later
  end
end
