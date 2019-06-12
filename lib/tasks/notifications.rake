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

  task slack_notifications: :environment do
    Team.all.each do |team|
      hour_now = Time.zone.now.hour
      next if team.slack_configurations.blank?

      slack_configs = team.slack_configurations.where(notification_hour: hour_now)
      next if slack_configs.blank?

      slack_configs.each { |slack_config| Slack::SlackNotificationsJob.perform_now(slack_config, team) }
    end
  end
end
