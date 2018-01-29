# frozen_string_literal: true

namespace :notifications do
  desc 'Notifications for the user'
  task companies_bulletin: :environment do
    if ENV['BULLETIN_WEEKLY_DAY'].present?
      CompaniesBulletimJob.perform_later if Time.zone.today.wday == ENV['BULLETIN_WEEKLY_DAY'].to_i
    else
      CompaniesBulletimJob.perform_later
    end
  end
end
