class CWorker
  include Sidekiq::Worker
  sidekiq_options queue: :c

  def perform
    sleep 10
  end
end

