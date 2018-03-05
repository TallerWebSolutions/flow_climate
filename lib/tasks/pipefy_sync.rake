# frozen_string_literal: true

namespace :synchronize do
  desc 'Process projects alerts'
  task pipefy_sync: :environment do
    ProcessPipefyPipeJob.perform_later(Figaro.env.perform_full_pipefy_read || false)
  end
end
