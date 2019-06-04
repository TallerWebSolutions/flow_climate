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
    include ActionView::Helpers::NumberHelper

    Team.all.each do |team|
      hour_now = Time.zone.now.hour
      next if team.slack_configurations.blank?

      config = team.slack_configurations.find_by(notification_hour: hour_now)
      next if config.blank?

      slack_notifier = Slack::Notifier.new(config.room_webhook)

      five_weeks_cmd = TeamService.instance.compute_average_demand_cost_to_team(team, 5.weeks.ago.beginning_of_week.to_date, Time.zone.today.end_of_week.to_date, 'week')

      next if five_weeks_cmd.nil?

      four_weeks_cmd_array = five_weeks_cmd.values[-5, 4].compact
      four_weeks_cmd_average = four_weeks_cmd_array.sum / four_weeks_cmd_array.count

      last_week = five_weeks_cmd.values[-1]

      cmd_difference_to_avg_last_four_weeks = ((last_week.to_f - four_weeks_cmd_average) / four_weeks_cmd_average) * 100

      slack_notifier.ping(I18n.t('slack_configurations.notifications.cmd_text', name: team.name, cmd_value: number_to_currency(last_week), cmd_difference_to_last_week: number_with_precision(cmd_difference_to_avg_last_four_weeks, precision: 2), previous_cmd: number_to_currency(four_weeks_cmd_average)))
    end
  end
end
