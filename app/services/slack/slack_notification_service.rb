# frozen_string_literal: true

module Slack
  class SlackNotificationService
    include Singleton

    include Rails.application.routes.url_helpers
    include ActionView::Helpers::NumberHelper
    include DateHelper

    def notify_cmd(slack_notifier, team)
      average_demand_cost_info = TeamService.instance.average_demand_cost_stats_info_hash(team)

      idle_roles = team.count_idle_by_role.map { |role, count| "#{I18n.t("activerecord.attributes.membership.enums.member_role.#{role}")} (#{count})" }.join(', ')
      info_block = { type: 'section', text: { type: 'mrkdwn', text: [
        ">*CMD para o time #{team.name}* -- TH: #{th_for_week(team, Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count}\n>",
        ">:money_with_wings: Semana atual: *#{number_to_currency(average_demand_cost_info[:current_week])}* -- Média das últimas 4 semanas: *#{number_to_currency(average_demand_cost_info[:four_weeks_cmd_average])}*",
        ">Diferença (atual e média): *#{number_with_precision(average_demand_cost_info[:cmd_difference_to_avg_last_four_weeks], precision: 2)}%*",
        ">:money_with_wings: Semana anterior: *#{number_to_currency(average_demand_cost_info[:last_week])}* -- TH: #{th_for_week(team, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week).count}",
        ">:busts_in_silhouette: Tamanho do time: *#{team.size_at} pessoas -- #{number_with_precision(team.size_using_available_hours, precision: 2)} pessoas faturáveis*",
        ">:zzz: #{number_to_percentage(team.percentage_idle_members * 100, precision: 0)}",
        ">:zzz: :busts_in_silhouette: #{idle_roles}"
      ].join("\n") } }
      divider_block = { type: 'divider' }
      slack_notifier.post(blocks: [info_block, divider_block])
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_team_review(slack_notifier, team)
      date = Time.zone.now
      business_days_in_month = TimeService.instance.business_days_between(date.beginning_of_month, date)
      info_block = { type: 'section', text: { type: 'mrkdwn', text: [
        ">*Team Review - #{team.name}*",
        ">*TH da semana: #{th_for_week(team, Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count}*\n>",
        ">:busts_in_silhouette: Tamanho do time: *#{team.size_at} pessoas -- #{number_with_precision(team.size_using_available_hours, precision: 2)} pessoas faturáveis*",
        ">:moneybag: Investimento mensal: *#{number_to_currency(team.monthly_investment)}* -- *#{team.available_hours_in_month_for}* horas",
        ">:chart_with_downwards_trend: Perda operacional no mês: *#{number_to_percentage(team.loss_at * 100)}* #{number_with_precision(team.consumed_hours_in_month(Time.zone.today), precision: 2)}h realizadas de *#{number_to_percentage(team.expected_loss_at * 100)}* - #{number_with_precision(team.expected_consumption, precision: 2)}h esperadas",
        ">:moneybag: Realizado no mês: *#{number_to_currency(team.realized_money_in_month(Time.zone.today))}*",
        ">*Dias úteis no mês: #{business_days_in_month}*\n>",
        ">Média de horas por pessoa faturável no mês: *#{number_with_precision(team.average_consumed_hours_per_person_per_day, precision: 2)}*"
      ].join("\n") } }
      divider_block = { type: 'divider' }
      slack_notifier.post(blocks: [info_block, divider_block])
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_week_throughput(slack_notifier, team)
      th_current_week = DemandsRepository.instance.throughput_to_period(team.demands.kept, Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count
      average_th_four_last_weeks = DemandsRepository.instance.throughput_to_period(team.demands.kept, 4.weeks.ago.beginning_of_week, 1.week.ago.end_of_week).count.to_f / 4.0

      th_difference_to_avg_last_four_weeks = 0
      th_difference_to_avg_last_four_weeks = ((th_current_week.to_f - average_th_four_last_weeks) / average_th_four_last_weeks) * 100 if average_th_four_last_weeks.positive?

      slack_notifier.ping(I18n.t('slack_configurations.notifications.th_week_text', name: team.name, th_current_week: th_current_week, difference_last_week_th_value: number_with_precision(th_difference_to_avg_last_four_weeks, precision: 2), four_weeks_th_average: average_th_four_last_weeks))
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_last_week_delivered_demands_info(slack_notifier, team)
      th_for_last_week = th_for_week(team, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
      delivered_count = th_for_last_week.count
      value_generated = th_for_last_week.sum(&:cost_to_project)
      average_value_per_demand = if delivered_count.positive?
                                   value_generated / delivered_count
                                 else
                                   0
                                 end

      message_text = [
        ">*Deliveries in the last week - #{team.name}*",
        "> #{I18n.t('slack_configurations.notifications.th_last_week_text', name: team.name, th_last_week: delivered_count)}",
        ">Horas: *#{number_with_precision(th_for_last_week.sum(&:total_effort), precision: 2)}* | *#{number_to_currency(value_generated)}* | Média: *#{number_to_currency(average_value_per_demand)}*",
        "> #{th_for_last_week.map { |d| "<#{company_demand_url(d.company, d.external_id)}|#{d.external_id}>" }.join(' | ')}"
      ].join("\n")

      delivered_last_week_message = {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: message_text
        }
      }

      slack_notifier.post(blocks: [delivered_last_week_message])
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end

    def notify_wip_demands(slack_notifier, team)
      demands_in_wip = team.demands.kept.in_wip(Time.zone.now).sort_by(&:flow_percentage_concluded).reverse

      slack_notifier.ping(I18n.t('slack_configurations.notifications.qty_demands_in_wip', team_name: team.name, in_wip: demands_in_wip.count))

      demands_in_wip.each do |demand|
        slack_notifier.ping(
          I18n.t('slack_configurations.notifications.demands_in_wip_info_text',
                 external_id: demand.external_id,
                 responsibles_names: demand.active_memberships.map(&:team_member_name).join(', '),
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
      demands_in_wip = team.demands.kept.in_wip(Time.zone.now).sort_by(&:flow_percentage_concluded).reverse
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

    def notify_demand_state_changed(stage, demand, demand_transition)
      return if demand_transition.transition_notified?

      slack_configurations = slack_configurations(demand, :demand_state_changed)

      unless slack_configurations.present? && stage.present?
        demand_transition.update(transition_notified: true)

        return
      end

      team_member = demand_transition.team_member

      change_state_notify = "*#{demand.external_id} - #{demand.demand_title}*\n:information_source: _#{team_member&.name || 'anônimo'}_ moveu para _#{stage.name}_ em #{I18n.l(demand_transition.last_time_in, format: :short)}"

      change_state_notify += if stage.end_point?
                               " :tada: \n"
                             else
                               "\n"
                             end

      change_state_notify += "> #{demand.work_item_type.name} - #{I18n.t("activerecord.attributes.demand.enums.class_of_service.#{demand.class_of_service}")}\n"
      change_state_notify += "> *Responsáveis:* #{demand.active_memberships.map(&:team_member_name).join(', ')} (_#{demand.team_name}_)\n"
      change_state_notify += "> *Unidade de portfólio:* #{demand.portfolio_unit&.name}\n" unless demand.portfolio_unit.nil?
      change_state_notify += ":alarm_clock: *Lead time (p80) de demandas similares* | *No Projeto*: #{time_distance_in_words(DemandService.instance.similar_p80_project(demand))} | *No Time:* #{time_distance_in_words(DemandService.instance.similar_p80_team(demand))}\n" if stage.commitment_point?

      if stage.end_point?
        change_state_notify += "> :alarm_clock: Lead Time: #{time_distance_in_words(demand.reload.leadtime)}\n"
        project = demand.project
        change_state_notify += "> :moneybag: #{number_to_currency(demand.cost_to_project, decimal: 2)} | Upstream: #{number_to_currency(demand.effort_upstream * project.hour_value, decimal: 2)} | Downstream: #{number_to_currency(demand.effort_downstream * project.hour_value, decimal: 2)} \n"
        team = demand.team

        change_state_notify += "> Mais rápida do que *#{number_to_percentage(project.lead_time_position_percentage(demand) * 100, precision: 1)}* das demandas no projeto *#{project.name}*.\n"
        change_state_notify += "> Mesmo tipo: *#{number_to_percentage(project.lead_time_position_percentage_same_type(demand) * 100, precision: 1)}* | Mesma Classe de Serviço: *#{number_to_percentage(project.lead_time_position_percentage_same_cos(demand) * 100, precision: 1)}*\n"
        change_state_notify += "> E no time *#{team.name}*, o lead time foi menor que *#{number_to_percentage(team.lead_time_position_percentage(demand) * 100, precision: 1)}* das demandas.\n"
        change_state_notify += "> Mesmo tipo: *#{number_to_percentage(team.lead_time_position_percentage_same_type(demand) * 100, precision: 1)}* | Mesma Classe de Serviço: *#{number_to_percentage(team.lead_time_position_percentage_same_cos(demand) * 100, precision: 1)}*\n"
      end

      slack_configurations.each do |config|
        next unless config.notify_stage?(stage)

        slack_notifier = Slack::Notifier.new(config.room_webhook)
        slack_notifier.ping(change_state_notify)
      end

      demand_transition.update(transition_notified: true)
    end

    def notify_item_assigned(item_assignment, demand_url)
      return if item_assignment.valid? == false

      slack_configurations = slack_configurations(item_assignment.demand, :item_assigned)

      if slack_configurations.blank?
        ItemAssignment.transaction { item_assignment.update(assignment_notified: true) }
        return
      end

      return if item_assignment.assignment_notified?

      demand_title = "*<#{demand_url}|#{item_assignment.demand.external_id} - #{item_assignment.demand.demand_title}>*"
      assign_message = "#{item_assignment.team_member_name} puxou a demanda em _#{item_assignment.assigned_at&.name || 'sem etapa'}_ às #{I18n.l(item_assignment.start_time, format: :short)}"
      message_previous_pull = "Anterior: #{item_assignment.previous_assignment&.demand&.external_id}"
      message_ongoing = ":computer: #{item_assignment.membership_open_assignments.map(&:demand).flatten.map { |demand| "#{demand.external_id} (#{demand.current_stage_name})" }.join(', ')}"
      message_idle = ":zzz: #{time_distance_in_words(item_assignment.pull_interval)} :zzz: :busts_in_silhouette: #{number_to_percentage(item_assignment.membership.team.percentage_idle_members * 100, precision: 0)}"

      info_block = { type: 'section', text: { type: 'mrkdwn', text: ">#{demand_title}\n>#{assign_message}\n>#{message_previous_pull}\n>#{message_ongoing}\n>#{message_idle}" } }
      divider_block = { type: 'divider' }

      slack_configurations.each do |config|
        slack_notifier = Slack::Notifier.new(config.room_webhook)
        slack_notifier.post(blocks: [info_block, divider_block])
      end

      ItemAssignment.transaction { item_assignment.update(assignment_notified: true) }
    end

    def notify_item_blocked(demand_block, demand_url, edit_block_url, block_state = 'blocked')
      slack_configurations = SlackConfiguration.where(team: demand_block.demand.team, info_type: 'demand_blocked', active: true)

      if slack_configurations.blank?
        Notifications::DemandBlockNotification.where(demand_block: demand_block, block_state: block_state).first_or_create
        return
      end

      already_notified = Notifications::DemandBlockNotification.where(demand_block: demand_block, block_state: block_state)

      return if already_notified.present?

      demand_type = I18n.t("activerecord.attributes.demand_block.enums.block_type.#{demand_block.block_type}")
      block_type = { type: 'section', text: { type: 'mrkdwn', text: ">*Tipo:* <#{edit_block_url}|#{demand_type}>\n> <@#{demand_block.blocker.user&.slack_user_for_company(demand_block.demand.company)}> #{I18n.t('slack_configurations.notifications.block_change_type_text')}" } }
      divider_block = { type: 'divider' }

      slack_configurations.each do |config|
        slack_notifier = Slack::Notifier.new(config.room_webhook)
        if block_state == 'blocked'
          notify_blocked(block_type, demand_block, demand_url, divider_block, slack_notifier)
        else
          notify_unblocked(block_type, demand_block, demand_url, divider_block, slack_notifier)
        end
      end

      Notifications::DemandBlockNotification.create(demand_block: demand_block, block_state: block_state)
    rescue Slack::Notifier::APIError => e
      Rails.logger.error("Invalid Slack API - #{e.message}")
    end

    def notify_team_efficiency(slack_notifier, team, start_date, end_date, title, notification_period)
      efficiency_data = TeamService.instance.compute_memberships_realized_hours(team, start_date, end_date)
      return if efficiency_data.blank?

      members_efforts = efficiency_data[:members_efficiency].reject { |member_effort| member_effort.try(:[], :membership).try(:[], :hours_per_month).blank? && member_effort.try(:[], :membership).try(:[], :hours_per_month)&.zero? }

      return if members_efforts.blank?

      effort_text = title

      members_efforts.each_with_index do |member, index|
        effort_text += "• #{medal_of_honor(index)} #{member[:membership].team_member.name} | Demandas: #{member[:cards_count]} | Horas: #{number_with_precision(member[:effort_in_month])} | Capacidade: #{member[:membership][:hours_per_month]} #{notification_period == 'month' ? "| Vl Hr: #{number_with_precision(member[:hour_value_realized])}" : ''}\n"
      end

      effort_info_block = { type: 'section', text: { type: 'mrkdwn', text: effort_text } }

      divider_block = { type: 'divider' }

      slack_notifier.post(blocks: [effort_info_block, divider_block])
    rescue Slack::Notifier::APIError => e
      Rails.logger.error("Invalid Slack API - #{e.message}")
    end

    private

    def slack_configurations(demand, info_type)
      slack_configurations_teams = SlackConfiguration.where(team: demand.team, info_type: info_type, config_type: :team, active: true)
      slack_configurations_customers = SlackConfiguration.where(customer: demand.customer, info_type: info_type, config_type: :customer, active: true)
      slack_configurations_teams + slack_configurations_customers
    end

    def th_for_week(team, start_date, end_date)
      DemandsRepository.instance.throughput_to_period(team.demands.kept, start_date, end_date)
    end

    def notify_unblocked(block_type, demand_block, demand_url, divider_block, slack_notifier)
      message_title = { type: 'section', text: { type: 'mrkdwn', text: ":tada: :tada: #{demand_block.unblocker&.name} desbloqueou a <#{demand_url}|#{demand_block.demand.external_id}> em _#{demand_block.demand.stage_at(demand_block.block_time)&.name || 'sem etapa'}_ as #{I18n.l(demand_block.unblock_time, format: :short)}" } }
      block_detail = { type: 'section', text: { type: 'mrkdwn', text: ":alarm_clock: #{time_distance_in_words(demand_block.reload.total_blocked_time)}" } }

      slack_notifier.post(blocks: [message_title, block_type, block_detail, divider_block])
    end

    def notify_blocked(block_type, demand_block, demand_url, divider_block, slack_notifier)
      message_title = { type: 'section', text: { type: 'mrkdwn', text: ">:no_entry_sign: #{demand_block.blocker_name} bloqueou a <#{demand_url}|#{demand_block.demand.external_id}> em _#{demand_block.demand.stage_at(demand_block.block_time)&.name || 'sem etapa'}_ as #{I18n.l(demand_block.block_time, format: :short)}" } }
      block_detail = { type: 'section', text: { type: 'mrkdwn', text: ">*Motivo:* #{demand_block.block_reason}" } }

      slack_notifier.post(blocks: [message_title, block_type, block_detail, divider_block])
    end

    def medal_of_honor(member_position)
      if member_position.zero?
        ':first_place_medal:'
      elsif member_position == 1
        ':second_place_medal:'
      elsif member_position == 2
        ':third_place_medal:'
      else
        ''
      end
    end
  end
end
