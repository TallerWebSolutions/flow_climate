# frozen_string_literal: true

class PurgeIntegrationErrorsJob < ApplicationJob
  queue_as :default

  def perform
    IntegrationError.where('created_at < :limit_date', limit_date: 3.days.ago).map(&:destroy)
  end
end
