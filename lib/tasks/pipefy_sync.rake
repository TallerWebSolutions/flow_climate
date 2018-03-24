# frozen_string_literal: true

namespace :synchronize do
  desc 'Sync the cards with pipefy'
  task pipefy_sync: :environment do
    ProcessPipefyPipeJob.perform_now
  end
end
