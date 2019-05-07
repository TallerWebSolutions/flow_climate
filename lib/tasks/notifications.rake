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

      notifier = Slack::Notifier.new(config.room_webhook)

      cmd = TeamService.instance.compute_average_demand_cost_to_team(team, Time.zone.today.beginning_of_week, Time.zone.today.end_of_week, 'week')

      notifier.ping(I18n.t('slack_configurations.notifications.cmd_text', name: team.name, number_to_currency: number_to_currency(cmd.values.last)))
    end
  end
end
