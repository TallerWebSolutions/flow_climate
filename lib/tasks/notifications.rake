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
      next if team.slack_configurations.blank? || Time.zone.today.saturday? || Time.zone.today.sunday?

      hour_now = Time.zone.now.hour
      minute_now = Time.zone.now.min
      weekday = Time.zone.now.wday

      slack_configs = team.slack_configurations.where('weekday_to_notify = 0 OR weekday_to_notify = :weekday_to_notify', weekday_to_notify: weekday)
      next if slack_configs.blank?

      slack_configs = team.slack_configurations.where(notification_hour: hour_now).where('notification_minute BETWEEN :minute_now_start AND :minute_now_end', minute_now_start: minute_now, minute_now_end: minute_now + 10)
      next if slack_configs.blank?

      slack_configs.each { |slack_config| Slack::SlackNotificationsJob.perform_now(slack_config, team) }
    end
  end
end
