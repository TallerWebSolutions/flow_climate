# frozen_string_literal: true

class CompaniesBulletimJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    Rails.logger.error "[#{self.class.name}] #{exception}"
  end

  def perform
    process_weekly_bulletin
  end

  private

  def process_weekly_bulletin
    Company.all.each do |company|
      Rails.logger.info("Notifying projects for #{company.name}")
      UserNotifierMailer.company_weekly_bulletin(company.users, company).deliver
    end
  end
end
