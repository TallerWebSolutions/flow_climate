module Slack
  class SlackNotificationsJob < ApplicationJob
    include ActionView::Helpers::NumberHelper
    include DateHelper

    def perform(slack_configuration, team)
      slack_notifier = Slack::Notifier.new(slack_configuration.room_webhook)

      if slack_configuration.average_demand_cost?
        notify_cmd(slack_notifier, team)
      elsif slack_configuration.current_week_throughput?
        notify_week_throughput(slack_notifier, team)
      elsif slack_configuration.last_week_delivered_demands_info?
        notify_last_week_delivered_demands_info(slack_notifier, team)
      elsif slack_configuration.demands_wip_info?
        notify_wip_demands(slack_notifier, team)
      elsif slack_configuration.outdated_demands?
        notify_beyond_expected_time_in_stage(slack_notifier, team)
      end
    end

    private

    def notify_cmd(slack_notifier, team)
      five_weeks_cmd = TeamService.instance.compute_average_demand_cost_to_team(team, 5.weeks.ago.beginning_of_week.to_date, Time.zone.today.end_of_week.to_date, 'week')

      return if five_weeks_cmd.nil?

      four_weeks_cmd_array = five_weeks_cmd.values[-5, 4].compact
      four_weeks_cmd_average = four_weeks_cmd_array.sum / four_weeks_cmd_array.count

      last_week = five_weeks_cmd.values[-1]

      cmd_difference_to_avg_last_four_weeks = 0
      cmd_difference_to_avg_last_four_weeks = ((last_week.to_f - four_weeks_cmd_average) / four_weeks_cmd_average) * 100 if four_weeks_cmd_average.positive?

      slack_notifier.ping(I18n.t('slack_configurations.notifications.cmd_text', name: team.name, cmd_value: number_to_currency(last_week), cmd_difference_to_last_week: number_with_precision(cmd_difference_to_avg_last_four_weeks, precision: 2), previous_cmd: number_to_currency(four_weeks_cmd_average)))
    end

    def notify_week_throughput(slack_notifier, team)
      th_current_week = DemandsRepository.instance.throughput_to_projects_and_period(team.projects, Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count
      average_th_four_last_weeks = DemandsRepository.instance.throughput_to_projects_and_period(team.projects, 4.weeks.ago.beginning_of_week, 1.week.ago.end_of_week).count.to_f / 4.0

      th_difference_to_avg_last_four_weeks = 0
      th_difference_to_avg_last_four_weeks = ((th_current_week.to_f - average_th_four_last_weeks) / average_th_four_last_weeks) * 100 if average_th_four_last_weeks.positive?

      slack_notifier.ping(I18n.t('slack_configurations.notifications.th_week_text', name: team.name, th_current_week: th_current_week, difference_last_week_th_value: number_with_precision(th_difference_to_avg_last_four_weeks, precision: 2), four_weeks_th_average: average_th_four_last_weeks))
    end

    def notify_last_week_delivered_demands_info(slack_notifier, team)
      th_last_week = DemandsRepository.instance.throughput_to_projects_and_period(team.projects, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
      slack_notifier.ping(I18n.t('slack_configurations.notifications.th_last_week_text', name: team.name, th_last_week: th_last_week.count))

      th_last_week.each do |demand|
        slack_notifier.ping(I18n.t('slack_configurations.notifications.th_last_week_demand_info_text', demand_id: demand.demand_id, responsibles_names: demand.team_members.map(&:name).join(', '), cost_to_project: number_to_currency(demand.cost_to_project), demand_title: demand.demand_title))
      end
    end

    def notify_wip_demands(slack_notifier, team)
      demands_in_wip = team.demands.in_wip.sort_by(&:flow_percentage_concluded).reverse

      slack_notifier.ping(I18n.t('slack_configurations.notifications.qty_demands_in_wip', team_name: team.name, in_wip: demands_in_wip.count))

      demands_in_wip.each do |demand|
        slack_notifier.ping(
            I18n.t('slack_configurations.notifications.demands_in_wip_info_text',
                   demand_id: demand.demand_id,
                   responsibles_names: demand.team_members.map(&:name).join(', '),
                   cost_to_project: number_to_currency(demand.cost_to_project),
                   demand_title: demand.demand_title,
                   current_stage: demand.current_stage&.name,
                   time_in_current_stage: time_distance_in_words(demand.time_in_current_stage),
                   percentage_concluded: number_to_percentage(demand.flow_percentage_concluded * 100, precision: 2))
        )
      end
    end

    def notify_beyond_expected_time_in_stage(slack_notifier, team)
      demands_in_wip = team.demands.in_wip.sort_by(&:flow_percentage_concluded).reverse
      demands_beyond_time = demands_in_wip.select(&:beyond_limit_time?)

      if demands_beyond_time.present?
        slack_notifier.ping(I18n.t('slack_configurations.notifications.beyond_expected_title', team_name: team.name, beyond_expected_count: demands_beyond_time.count))

        demands_beyond_time.each do |outdated_demand|
          slack_notifier.ping(
              I18n.t('slack_configurations.notifications.outdated_demands_info_text',
                     demand_id: outdated_demand.demand_id,
                     demand_title: outdated_demand.demand_title,
                     current_stage: outdated_demand.current_stage&.name,
                     time_in_current_stage: time_distance_in_words(outdated_demand.time_in_current_stage))
          )
        end
      end
    end
  end
end
