# frozen_string_literal: true

namespace :notifications do
  desc 'Notifications for the user'

  task slack_notifications: :environment do
    Team.find_each do |team|
      next if team.slack_configurations.blank? || Time.zone.today.saturday? || Time.zone.today.sunday?

      hour_now = Time.zone.now.hour
      minute_now = Time.zone.now.min
      weekday = Time.zone.now.wday

      slack_configs = team.slack_configurations.active_configurations.where('weekday_to_notify = 0 OR weekday_to_notify = :weekday_to_notify', weekday_to_notify: weekday)
      next if slack_configs.blank?

      slack_configs = slack_configs.where('(notification_hour = :hour_now AND notification_minute BETWEEN :minute_now AND :minute_plus_nine) OR (notification_hour = :hour_plus_one AND notification_minute <= 9 AND EXTRACT(MINUTE FROM current_timestamp) >= 50)',
                                          hour_now: hour_now,
                                          minute_now: minute_now,
                                          minute_plus_nine: minute_now + 9,
                                          hour_plus_one: hour_now + 1)

      next if slack_configs.blank?

      slack_configs.each { |slack_config| Slack::SlackNotificationsJob.perform_now(slack_config, team) }
    end
  end

  task slack_notifications_for_demands: :environment do
    Team.find_each do |team|
      next if team.slack_configurations.blank? || !team.active?

      Slack::DemandSlackNotificationsJob.perform_now(team)
    end
  end
end
