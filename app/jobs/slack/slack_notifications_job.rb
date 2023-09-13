# frozen_string_literal: true

module Slack
  class SlackNotificationsJob < ApplicationJob
    def perform(slack_configuration, team)
      slack_notifier = Slack::Notifier.new(slack_configuration.room_webhook)

      if slack_configuration.average_demand_cost?
        Slack::SlackNotificationService.instance.notify_cmd(slack_notifier, team)
      elsif slack_configuration.current_week_throughput?
        Slack::SlackNotificationService.instance.notify_week_throughput(slack_notifier, team)
      elsif slack_configuration.last_week_delivered_demands_info?
        Slack::SlackNotificationService.instance.notify_last_week_delivered_demands_info(slack_notifier, team)
      elsif slack_configuration.demands_wip_info?
        Slack::SlackNotificationService.instance.notify_wip_demands(slack_notifier, team)
      elsif slack_configuration.outdated_demands?
        Slack::SlackNotificationService.instance.notify_beyond_expected_time_in_stage(slack_notifier, team)
      elsif slack_configuration.failure_load?
        Slack::SlackNotificationService.instance.notify_failure_load(slack_notifier, team)
      elsif slack_configuration.team_review?
        Slack::SlackNotificationService.instance.notify_team_review(slack_notifier, team)
      elsif slack_configuration.weekly_team_efficiency?
        start_date = Time.zone.now.beginning_of_week
        end_date = Time.zone.now.end_of_week
        title = ">*#{I18n.t('slack_configurations.notifications.notify_week_team_efficiency.title', team_name: team.name)}*\n\n"
        notification_period = "week"

        Slack::SlackNotificationService.instance.notify_team_efficiency(slack_notifier, team, start_date, end_date, title, notification_period)

      elsif slack_configuration.monthly_team_efficiency?
        start_date = Time.zone.now.beginning_of_month
        end_date = Time.zone.now.end_of_month
        title = ">*#{I18n.t('slack_configurations.notifications.notify_month_team_efficiency.title', team_name: team.name)} em #{I18n.l(start_date, format: '%B')}/#{start_date.year}*\n\n"
        notification_period = "month"
        Slack::SlackNotificationService.instance.notify_team_efficiency(slack_notifier, team, start_date, end_date, title, notification_period)
      end
    end
  end
end
