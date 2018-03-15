# frozen_string_literal: true

namespace :synchronize do
  desc 'Sync the cards with pipefy'
  task pipefy_sync: :environment do
    ProcessPipefyPipeJob.perform_now(Figaro.env.perform_full_pipefy_read || false)
  end
end
