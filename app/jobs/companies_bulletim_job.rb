# frozen_string_literal: true

class CompaniesBulletimJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    Rails.logger.error "[#{self.class.name}] #{exception}"
  end

  def perform
    process_weekly_bulletin if Time.zone.today.monday?
  end

  private

  def process_weekly_bulletin
    Company.all.each do |company|
      Rails.logger.info("Notifying projects for #{company.name}")
      UserNotifierMailer.company_weekly_bulletin(company, company.projects.waiting_projects_starting_within_week, company.projects.executing_projects_finishing_within_week).deliver
    end
  end
end
