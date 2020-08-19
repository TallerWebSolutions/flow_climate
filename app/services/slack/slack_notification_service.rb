# frozen_string_literal: true

module Slack
  class SlackNotificationService
    include Singleton

    include ActionView::Helpers::NumberHelper
    include DateHelper
    include ActionView::Helpers::UrlHelper

    def notify_cmd(slack_notifier, team)
      average_demand_cost_info = TeamService.instance.average_demand_cost_stats_info_hash(team)

      slack_notifier.ping(I18n.t('slack_configurations.notifications.cmd_text',
                                 name: average_demand_cost_info[:team_name],
                                 cmd_value: number_to_currency(average_demand_cost_info[:current_week]),
                                 last_week_cmd: number_to_currency(average_demand_cost_info[:last_week]),
                                 cmd_difference_to_last_week: number_with_precision(average_demand_cost_info[:cmd_difference_to_avg_last_four_weeks], precision: 2),
                                 previous_cmd: number_to_currency(average_demand_cost_info[:four_weeks_cmd_average])))
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_week_throughput(slack_notifier, team)
      th_current_week = DemandsRepository.instance.throughput_to_period(team.demands, Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count
      average_th_four_last_weeks = DemandsRepository.instance.throughput_to_period(team.demands, 4.weeks.ago.beginning_of_week, 1.week.ago.end_of_week).count.to_f / 4.0

      th_difference_to_avg_last_four_weeks = 0
      th_difference_to_avg_last_four_weeks = ((th_current_week.to_f - average_th_four_last_weeks) / average_th_four_last_weeks) * 100 if average_th_four_last_weeks.positive?

      slack_notifier.ping(I18n.t('slack_configurations.notifications.th_week_text', name: team.name, th_current_week: th_current_week, difference_last_week_th_value: number_with_precision(th_difference_to_avg_last_four_weeks, precision: 2), four_weeks_th_average: average_th_four_last_weeks))
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_last_week_delivered_demands_info(slack_notifier, team)
      th_last_week = DemandsRepository.instance.throughput_to_period(team.demands, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
      slack_notifier.ping(I18n.t('slack_configurations.notifications.th_last_week_text', name: team.name, th_last_week: th_last_week.count))

      th_last_week.each do |demand|
        slack_notifier.ping(I18n.t('slack_configurations.notifications.th_last_week_demand_info_text', external_id: demand.external_id, responsibles_names: demand.memberships.map(&:team_member_name).join(', '), cost_to_project: number_to_currency(demand.cost_to_project), demand_title: demand.demand_title))
      end
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_wip_demands(slack_notifier, team)
      demands_in_wip = team.demands.in_wip.sort_by(&:flow_percentage_concluded).reverse

      slack_notifier.ping(I18n.t('slack_configurations.notifications.qty_demands_in_wip', team_name: team.name, in_wip: demands_in_wip.count))

      demands_in_wip.each do |demand|
        slack_notifier.ping(
          I18n.t('slack_configurations.notifications.demands_in_wip_info_text',
                 external_id: demand.external_id,
                 responsibles_names: demand.active_team_members.map(&:team_member_name).join(', '),
                 cost_to_project: number_to_currency(demand.cost_to_project),
                 demand_title: demand.demand_title,
                 current_stage: demand.current_stage&.name,
                 time_in_current_stage: time_distance_in_words(demand.time_in_current_stage),
                 percentage_concluded: number_to_percentage(demand.flow_percentage_concluded * 100, precision: 2))
        )
      end
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_beyond_expected_time_in_stage(slack_notifier, team)
      demands_in_wip = team.demands.in_wip.sort_by(&:flow_percentage_concluded).reverse
      demands_beyond_time = demands_in_wip.select(&:beyond_limit_time?)

      return if demands_beyond_time.blank?

      slack_notifier.ping(I18n.t('slack_configurations.notifications.beyond_expected_title', team_name: team.name, beyond_expected_count: demands_beyond_time.count))

      demands_beyond_time.each do |outdated_demand|
        slack_notifier.ping(
          I18n.t('slack_configurations.notifications.outdated_demands_info_text',
                 external_id: outdated_demand.external_id,
                 demand_title: outdated_demand.demand_title,
                 current_stage: outdated_demand.current_stage&.name,
                 time_in_current_stage: time_distance_in_words(outdated_demand.time_in_current_stage))
        )
      end
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_failure_load(slack_notifier, team)
      return unless team.demands.count.positive?

      running_projects = team.projects.running.order(:end_date)

      slack_notifier.ping(I18n.t('slack_configurations.notifications.failure_load', team_name: team.name, failure_load: number_to_percentage(team.failure_load, precision: 2)))

      running_projects.each do |project|
        slack_notifier.ping(I18n.t('slack_configurations.notifications.project_failure_load', team_name: team.name, project_name: project.name, failure_load: number_to_percentage(project.failure_load, precision: 2)))
      end
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_demand_state_changed(stage, demand, team_member)
      slack_configuration = SlackConfiguration.find_by(team: demand.team, info_type: :demand_state_changed, active: true)

      unless slack_configuration.present? && slack_configuration.notify_stage?(stage)
        Notifications::DemandTransitionNotification.create(stage: stage, demand: demand)

        return
      end

      already_notified = Notifications::DemandTransitionNotification.where(stage: stage, demand: demand)

      return if already_notified.present?

      slack_notifier = Slack::Notifier.new(slack_configuration.room_webhook)

      change_state_notify = "*#{demand.external_id} - #{demand.demand_title}*\n:information_source: _#{team_member.name}_ moveu para _#{stage.name}_"

      change_state_notify += if stage.end_point?
                               " :tada: \n"
                             else
                               "\n"
                             end

      change_state_notify += "> #{I18n.t("activerecord.attributes.demand.enums.demand_type.#{demand.demand_type}")} - #{I18n.t("activerecord.attributes.demand.enums.class_of_service.#{demand.class_of_service}")}\n"
      change_state_notify += "> *Responsáveis:* #{demand.active_team_members.map(&:team_member_name).join(', ')} (_#{demand.team_name}_)\n"

      change_state_notify += "> :alarm_clock: #{time_distance_in_words(demand.reload.leadtime)} | :moneybag: #{number_to_currency(demand.cost_to_project, decimal: 2)}\n" if stage.end_point?

      slack_notifier.ping(change_state_notify)

      Notifications::DemandTransitionNotification.create(stage: stage, demand: demand)
    end

    def notify_item_assigned(item_assignment)
      slack_configuration = SlackConfiguration.find_by(team: item_assignment.demand.team, info_type: 'item_assigned', active: true)

      if slack_configuration.blank?
        Notifications::ItemAssignmentNotification.where(item_assignment: item_assignment).first_or_create
        return
      end

      already_notified = Notifications::ItemAssignmentNotification.where(item_assignment: item_assignment)

      return if already_notified.present?

      slack_notifier = Slack::Notifier.new(slack_configuration.room_webhook)

      message_title =  { "type": 'section', "text": { "type": 'mrkdwn', "text": "#{item_assignment.team_member_name} puxou a _#{item_assignment.demand.external_id}_ em _#{item_assignment.assigned_at&.name || 'sem etapa'}_" } }
      message_divider = { "type": 'divider' }
      message_previous_pull = { "type": 'section', "text": { "type": 'mrkdwn', "text": "Anterior: #{item_assignment.previous_assignment&.demand&.external_id}" } }
      message_ongoing = { "type": 'section', "text": { "type": 'mrkdwn', "text": ":computer: #{item_assignment.membership_open_assignments.map(&:demand).flatten.map { |demand| "#{demand.external_id} (#{demand.current_stage_name})" }.join(', ')}" } }
      message_idle = { "type": 'context', "elements": [{ "type": 'mrkdwn', "text": ":zzz: #{time_distance_in_words(item_assignment.pull_interval)} :zzz: :busts_in_silhouette: #{number_to_percentage(item_assignment.membership.team.percentage_idle_members * 100, precision: 0)}" }] }

      divider_block = { "type": 'divider' }

      slack_notifier.post(blocks: [message_title, message_divider, message_previous_pull, message_ongoing, message_idle, divider_block])

      Notifications::ItemAssignmentNotification.create(item_assignment: item_assignment)
    end

    def notify_item_blocked(demand_block, demand_url, block_state = 'blocked')
      slack_configuration = SlackConfiguration.find_by(team: demand_block.demand.team, info_type: 'demand_blocked', active: true)

      if slack_configuration.blank?
        Notifications::DemandBlockNotification.where(demand_block: demand_block, block_state: block_state).first_or_create
        return
      end

      already_notified = Notifications::DemandBlockNotification.where(demand_block: demand_block, block_state: block_state)

      return if already_notified.present?

      slack_notifier = Slack::Notifier.new(slack_configuration.room_webhook)

      if block_state == 'blocked'
        message_title =  { "type": 'section', "text": { "type": 'mrkdwn', "text": ":no_entry_sign: #{demand_block.blocker_name} bloqueou a <#{demand_url}|#{demand_block.demand.external_id}> em _#{demand_block.demand.stage_at(demand_block.block_time)&.name || 'sem etapa'}_ as #{I18n.l(demand_block.block_time, format: :short)}" } }
        block_detail = { "type": 'section', "text": { "type": 'mrkdwn', "text": "*Motivo:* #{demand_block.block_reason}" } }
      else
        message_title =  { "type": 'section', "text": { "type": 'mrkdwn', "text": ":tada: :tada: #{demand_block.unblocker.name} desbloqueou a <#{demand_url}|#{demand_block.demand.external_id}> em _#{demand_block.demand.stage_at(demand_block.block_time)&.name || 'sem etapa'}_ as #{I18n.l(demand_block.unblock_time, format: :short)}" } }
        block_detail = { "type": 'section', "text": { "type": 'mrkdwn', "text": "*Tipo:* #{I18n.t("activerecord.attributes.demand_block.enums.block_type.#{demand_block.block_type}")} - :alarm_clock: #{time_distance_in_words(demand_block.reload.total_blocked_time)}" } }
      end

      divider_block = { "type": 'divider' }

      slack_notifier.post(blocks: [message_title, block_detail, divider_block])

      Notifications::DemandBlockNotification.create(demand_block: demand_block, block_state: block_state)
    end
  end
end
