# frozen_string_literal: true

RSpec.describe Slack::SlackNotificationService, type: :service do
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  let(:first_user) { Fabricate :user }

  let!(:company) { Fabricate :company, users: [first_user] }

  let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
  let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
  let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

  let(:team) { Fabricate :team, company: company, name: 'team' }
  let!(:team_member) { Fabricate :team_member, monthly_payment: 10_000, start_date: 5.weeks.ago, end_date: nil, name: 'team_member' }
  let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

  let!(:first_slack_config) { Fabricate :slack_configuration, team: team, info_type: :current_week_throughput, room_webhook: 'http://foo.com' }
  let!(:second_slack_config) { Fabricate :slack_configuration, team: team, info_type: :current_week_throughput, room_webhook: 'http://bla.com' }
  let!(:first_slack_notifier) { Slack::Notifier.new(first_slack_config.room_webhook) }
  let!(:project) { Fabricate :project, team: team, company: company, status: :executing, name: 'project' }

  let!(:stage) { Fabricate :stage, company: company, stage_stream: :downstream, name: 'stage' }
  let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage, project: project, max_seconds_in_stage: 1.day }

  context 'with data' do
    describe '#notify_cmd' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          travel_to Time.zone.local(2022, 6, 27, 10) do
            Fabricate :demand, team: team, project: project, work_item_type: chore_type, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 3.weeks.ago
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 2.hours.ago
            Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: 3.weeks.ago
            Fabricate :demand, team: team, project: project, work_item_type: chore_type, end_date: Time.zone.now
            Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: 2.weeks.ago
            Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: Time.zone.now
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: Time.zone.now

            average_demand_cost_info = TeamService.instance.average_demand_cost_stats_info_hash(team)

            idle_roles = team.count_idle_by_role.map { |role, count| "#{I18n.t("activerecord.attributes.membership.enums.member_role.#{role}")} (#{count})" }.join(', ')
            info_block = { type: 'section', text: { type: 'mrkdwn', text: [
              ">*CMD para o time #{team.name}* -- TH: 4\n>",
              ">:money_with_wings: Semana atual: *#{number_to_currency(average_demand_cost_info[:current_week])}* -- Média das últimas 4 semanas: *#{number_to_currency(average_demand_cost_info[:four_weeks_cmd_average])}*",
              ">Diferença (atual e média): *#{number_with_precision(average_demand_cost_info[:cmd_difference_to_avg_last_four_weeks], precision: 2)}%*",
              ">:money_with_wings: Semana anterior: *#{number_to_currency(average_demand_cost_info[:last_week])}* -- TH: 1",
              ">:busts_in_silhouette: Tamanho do time: *#{team.size_at} pessoas -- #{number_with_precision(team.size_using_available_hours, precision: 2)} pessoas faturáveis*",
              ">:zzz: #{number_to_percentage(team.percentage_idle_members * 100, precision: 0)}",
              ">:zzz: :busts_in_silhouette: #{idle_roles}"
            ].join("\n") } }

            divider_block = { type: 'divider' }

            expect_any_instance_of(Slack::Notifier).to receive(:post).with(blocks: [info_block, divider_block]).once
            described_class.instance.notify_cmd(first_slack_notifier, team)
          end
        end
      end

      context 'with exceptions' do
        it 'logs the error' do
          allow(first_slack_notifier).to(receive(:post)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))
          described_class.instance.notify_cmd(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_team_review' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          travel_to Time.zone.local(2022, 6, 27, 10) do
            date = Time.zone.now
            business_days_in_month = TimeService.instance.business_days_between(date.beginning_of_month, date)
            info_block = { type: 'section', text: { type: 'mrkdwn', text: [
              ">*Team Review - #{team.name}*",
              ">*TH da semana: 0*\n>",
              ">:busts_in_silhouette: Tamanho do time: *#{team.size_at} pessoas -- #{number_with_precision(team.size_using_available_hours, precision: 2)} pessoas faturáveis*",
              ">:moneybag: Investimento mensal: *#{number_to_currency(team.monthly_investment)}* -- *#{team.available_hours_in_month_for}* horas",
              ">:chart_with_downwards_trend: Perda operacional no mês: *#{number_to_percentage(team.loss_at * 100)}* #{number_with_precision(team.consumed_hours_in_month(Time.zone.today), precision: 2)}h realizadas de *#{number_to_percentage(team.expected_loss_at * 100)}* - #{number_with_precision(team.expected_consumption, precision: 2)}h esperadas",
              ">:moneybag: Realizado no mês: *#{number_to_currency(team.realized_money_in_month(Time.zone.today))}*",
              ">*Dias úteis no mês: #{business_days_in_month}*\n>",
              ">Média de horas por pessoa faturável no mês: *#{number_with_precision(team.average_consumed_hours_per_person_per_day, precision: 2)}*"
            ].join("\n") } }

            divider_block = { type: 'divider' }

            expect_any_instance_of(Slack::Notifier).to receive(:post).with(blocks: [info_block, divider_block]).once
            described_class.instance.notify_team_review(first_slack_notifier, team)
          end
        end
      end

      context 'with exceptions' do
        it 'logs the error' do
          allow(first_slack_notifier).to(receive(:post)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))
          described_class.instance.notify_team_review(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_week_throughput' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          travel_to Time.zone.local(2022, 7, 5, 10) do
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 3.weeks.ago
            Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 2.days.ago
            Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: 3.weeks.ago
            Fabricate :demand, team: team, project: project, work_item_type: chore_type, end_date: Time.zone.now
            Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: 2.weeks.ago
            Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: Time.zone.now
            Fabricate :demand, team: team, project: project, work_item_type: chore_type, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300

            expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Throughput na semana: *2 demanda(s)* | Variação: *60,00%* para a média das últimas 4 semanas (1.25).").once
            described_class.instance.notify_week_throughput(first_slack_notifier, team)
          end
        end
      end

      context 'with exceptions' do
        it 'never calls slack notification method and raises the error' do
          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_week_throughput(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_last_week_delivered_demands_info' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          travel_to Time.zone.local(2020, 3, 19, 10, 0, 0) do
            project = Fabricate :project
            first_demand = Fabricate :demand, team: team, project: project, end_date: 1.week.ago
            second_demand = Fabricate :demand, team: team, project: project, end_date: 1.week.ago
            Fabricate :demand, team: team, project: project, end_date: Time.zone.now

            team_member = Fabricate :team_member, name: 'foo'
            other_team_member = Fabricate :team_member, name: 'bar'
            membership = Fabricate :membership, team_member: team_member
            other_membership = Fabricate :membership, team_member: other_team_member
            Fabricate :item_assignment, membership: membership, demand: first_demand, start_time: 3.days.ago, finish_time: 2.days.ago
            Fabricate :item_assignment, membership: membership, demand: first_demand, start_time: 1.day.ago, finish_time: Time.zone.now
            Fabricate :item_assignment, membership: other_membership, demand: second_demand, start_time: 3.days.ago, finish_time: 2.days.ago

            th_for_last_week = [first_demand, second_demand]
            delivered_count = th_for_last_week.count
            value_generated = th_for_last_week.sum(&:cost_to_project)
            average_value_per_demand = value_generated / delivered_count

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

            message = { blocks: [delivered_last_week_message] }

            expect_any_instance_of(Slack::Notifier).to receive(:post).with(message).once

            described_class.instance.notify_last_week_delivered_demands_info(first_slack_notifier, team)
          end
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          allow(first_slack_notifier).to(receive(:post)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_last_week_delivered_demands_info(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_wip_demands' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          demand = Fabricate :demand, team: team, project: project, work_item_type: chore_type, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 3.days.ago

          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Trabalho em progresso: 1 demanda(s).").once
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{demand.external_id}* #{demand.demand_title} | *Responsáveis:*  | *Custo pro Projeto:* #{number_to_currency(demand.cost_to_project)} | *Etapa atual:* #{stage.name} | *Tempo na Etapa:* 3 dias | *% Fluxo Concluído*: 100,00%").once

          described_class.instance.notify_wip_demands(first_slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_wip_demands(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_beyond_expected_time_in_stage' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          demand = Fabricate :demand, team: team, project: project, work_item_type: chore_type, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 3.days.ago

          expect_any_instance_of(Slack::Notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.beyond_expected_title', team_name: team.name, beyond_expected_count: 1)).once
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{demand.external_id}* #{demand.demand_title} | *Etapa atual:* #{stage.name} | *Tempo na Etapa:* 3 dias").once

          described_class.instance.notify_beyond_expected_time_in_stage(first_slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'never calls the slack notification method and raises the exception' do
          demand = Fabricate :demand, team: team, project: project, work_item_type: chore_type, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 3.days.ago

          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_beyond_expected_time_in_stage(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_failure_load' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10
          Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 3.weeks.ago
          Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 2.days.ago
          Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: 3.weeks.ago
          Fabricate :demand, team: team, project: project, work_item_type: chore_type, end_date: Time.zone.now
          Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: 2.weeks.ago
          Fabricate :demand, team: team, project: project, work_item_type: feature_type, end_date: Time.zone.now
          Fabricate :demand, team: team, project: project, work_item_type: chore_type, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300

          slack_notifier = instance_double(Slack::Notifier)

          allow(Project).to receive(:running) { Project.all }
          expect(slack_notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.failure_load', team_name: team.name, failure_load: number_to_percentage(team.failure_load, precision: 2))).once
          expect(slack_notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.project_failure_load', team_name: team.name, project_name: project.name, failure_load: number_to_percentage(project.failure_load, precision: 2))).once

          described_class.instance.notify_failure_load(slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          Fabricate :demand, team: team, project: project, work_item_type: bug_type, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10

          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))
          described_class.instance.notify_failure_load(first_slack_notifier, team)
        end
      end
    end
  end

  context 'with no projects to collect data' do
    describe '#notify_cmd' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:post).once
        described_class.instance.notify_cmd(first_slack_notifier, team)
      end
    end

    describe '#notify_week_throughput' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Throughput na semana: *0 demanda(s)* | Variação: *0,00%* para a média das últimas 4 semanas (0.0).").once
        described_class.instance.notify_week_throughput(first_slack_notifier, team)
      end
    end

    describe '#notify_last_week_delivered_demands_info' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:post).once

        described_class.instance.notify_last_week_delivered_demands_info(first_slack_notifier, team)
      end
    end

    describe '#notify_wip_demands' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Trabalho em progresso: 0 demanda(s).").once

        described_class.instance.notify_wip_demands(first_slack_notifier, team)
      end
    end

    describe '#notify_beyond_expected_time_in_stage' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).not_to receive(:ping)

        described_class.instance.notify_beyond_expected_time_in_stage(first_slack_notifier, team)
      end
    end

    describe '#notify_failure_load' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).not_to receive(:ping)

        described_class.instance.notify_failure_load(first_slack_notifier, team)
      end
    end
  end

  describe '#notify_demand_state_changed' do
    context 'with no end_point stage' do
      context 'with team' do
        it 'calls slack notification' do
          stage = Fabricate :stage, end_point: false
          demand = Fabricate :demand, team: team
          team_member = Fabricate :team_member
          demand_transition = Fabricate :demand_transition, stage: stage, demand: demand, team_member: team_member
          Fabricate :slack_configuration, team: team, info_type: :demand_state_changed, stages_to_notify_transition: [stage.id]

          expect_any_instance_of(Slack::Notifier).to receive(:ping).with(/#{team_member.name}/)

          described_class.instance.notify_demand_state_changed(stage, demand, demand_transition)
        end
      end

      context 'with customer' do
        it 'calls slack notification method' do
          stage = Fabricate :stage, end_point: false
          customer = Fabricate :customer
          demand = Fabricate :demand, team: team, customer: customer
          team_member = Fabricate :team_member
          demand_transition = Fabricate :demand_transition, stage: stage, demand: demand, team_member: team_member
          Fabricate :slack_configuration, customer: customer, info_type: :demand_state_changed, stages_to_notify_transition: [stage.id], config_type: :customer

          expect_any_instance_of(Slack::Notifier).to receive(:ping).with(/#{team_member.name}/)

          described_class.instance.notify_demand_state_changed(stage, demand, demand_transition)
        end
      end

      it 'calls slack notification method with only targeted customer' do
        stage = Fabricate :stage, end_point: false
        customer = Fabricate :customer
        customer_two = Fabricate :customer
        demand = Fabricate :demand, team: team, customer: customer
        team_member = Fabricate :team_member
        demand_transition = Fabricate :demand_transition, stage: stage, demand: demand, team_member: team_member
        Fabricate :slack_configuration, customer: customer, info_type: :demand_state_changed, stages_to_notify_transition: [stage.id], config_type: :customer
        Fabricate :slack_configuration, customer: customer_two, info_type: :demand_state_changed, stages_to_notify_transition: [stage.id], config_type: :customer

        expect_any_instance_of(Slack::Notifier).to receive(:ping).with(/#{team_member.name}/).once

        described_class.instance.notify_demand_state_changed(stage, demand, demand_transition)
      end
    end

    context 'with an end_point stage' do
      it 'calls slack notification method' do
        stage = Fabricate :stage, end_point: true
        demand = Fabricate :demand, team: team
        team_member = Fabricate :team_member
        demand_transition = Fabricate :demand_transition, demand: demand, stage: stage, team_member: team_member
        first_config = Fabricate :slack_configuration, team: team, info_type: :demand_state_changed, stages_to_notify_transition: [stage.id]
        second_config = Fabricate :slack_configuration, team: team, info_type: :demand_state_changed, stages_to_notify_transition: [stage.id]

        expect_any_instance_of(Project).to receive(:lead_time_position_percentage_same_type).once.and_return(0.1)
        expect_any_instance_of(Project).to receive(:lead_time_position_percentage_same_cos).once.and_return(0.3)
        expect_any_instance_of(Project).to receive(:lead_time_position_percentage).once.and_return(0.15)

        first_notifier = instance_double(Slack::Notifier, ping: 'bla')
        second_notifier = instance_double(Slack::Notifier, ping: 'ble')

        allow(Slack::Notifier).to(receive(:new).with(first_config.room_webhook)).and_return(first_notifier)
        allow(Slack::Notifier).to(receive(:new).with(second_config.room_webhook)).and_return(second_notifier)

        expect(first_notifier).to receive(:ping).once
        expect(second_notifier).to receive(:ping).once

        described_class.instance.notify_demand_state_changed(stage, demand, demand_transition)
      end
    end
  end

  describe '#notify_item_assigned' do
    context 'with valid assignment' do
      it 'calls slack notification method' do
        demand = Fabricate :demand, team: team
        team_member = Fabricate :team_member
        membership = Fabricate :membership, team_member: team_member
        item_assignment = Fabricate :item_assignment, membership: membership, demand: demand, assignment_notified: false

        Fabricate :slack_configuration, team: team, info_type: :item_assigned, active: true

        expect_any_instance_of(Slack::Notifier).to receive(:post)

        described_class.instance.notify_item_assigned(item_assignment, 'htto://foo.bar/baz')
        expect(item_assignment.reload.assignment_notified?).to be true
      end
    end

    context 'with invalid assignment' do
      it 'returns with nothing' do
        demand = Fabricate :demand, team: team
        team_member = Fabricate :team_member
        membership = Fabricate :membership, team_member: team_member
        dup_item_assignment = Fabricate.build :item_assignment, membership: membership, demand: demand, assignment_notified: false

        allow(dup_item_assignment).to(receive(:valid?).and_return(false))

        Fabricate :slack_configuration, team: team, info_type: :item_assigned, active: true

        expect_any_instance_of(Slack::Notifier).not_to receive(:post)

        described_class.instance.notify_item_assigned(dup_item_assignment, 'htto://foo.bar/baz')
      end
    end
  end

  describe '#notify_item_blocked' do
    context 'when there is no config' do
      it 'calls slack notification method, creates the notification but do not send any' do
        demand = Fabricate :demand, team: team
        demand_block = Fabricate :demand_block, demand: demand
        Notifications::DemandBlockNotification.destroy_all

        expect_any_instance_of(Slack::Notifier).not_to receive(:post)

        described_class.instance.notify_item_blocked(demand_block, 'http://foo.com', 'http://bar.com')
        expect(Notifications::DemandBlockNotification.all.count).to eq 1
      end
    end

    context 'when blocked' do
      it 'calls slack notification method' do
        demand = Fabricate :demand, team: team
        demand_block = Fabricate :demand_block, demand: demand
        Notifications::DemandBlockNotification.destroy_all

        Fabricate :slack_configuration, team: team, info_type: :demand_blocked, active: true

        expect_any_instance_of(Slack::Notifier).to receive(:post)

        described_class.instance.notify_item_blocked(demand_block, 'http://foo.com', 'http://bar.com')
        expect(Notifications::DemandBlockNotification.all.count).to eq 1
      end
    end

    context 'when unblocked' do
      it 'calls slack notification method' do
        demand = Fabricate :demand, team: team
        unblocker = Fabricate :team_member
        demand_block = Fabricate :demand_block, demand: demand, unblocker: unblocker, unblock_time: Time.zone.now
        Notifications::DemandBlockNotification.destroy_all

        Fabricate :slack_configuration, team: team, info_type: :demand_blocked, active: true

        expect_any_instance_of(Slack::Notifier).to receive(:post)

        described_class.instance.notify_item_blocked(demand_block, 'http://foo.com', 'http://bar.com', 'unblocked')
        expect(Notifications::DemandBlockNotification.all.count).to eq 1
      end
    end

    context 'with exceptions' do
      it 'logs the error' do
        Fabricate :slack_configuration, team: team, info_type: :demand_blocked, active: true
        demand = Fabricate :demand, team: team
        demand_block = Fabricate :demand_block, demand: demand

        allow_any_instance_of(Slack::Notifier).to(receive(:post)).and_raise(Slack::Notifier::APIError)
        expect(Rails.logger).to(receive(:error)).once

        described_class.instance.notify_item_blocked(demand_block, 'http://foo.com', 'http://bar.com', 'blocked')
      end
    end
  end

  describe '#notify_team_efficiency' do
    context 'with efforts' do
      it 'calls slack notification method' do
        Fabricate :demand, team: team
        first_member = Fabricate :team_member, company: company, name: 'Foo do Bar', billable: true
        second_member = Fabricate :team_member, company: company, name: 'Xpto Sbbrubles', billable: true
        third_member = Fabricate :team_member, company: company, name: 'Truco Sbbrubles', billable: true

        first_membership = Fabricate :membership, team: team, team_member: first_member, hours_per_month: 100, start_date: 1.day.ago, end_date: nil
        second_membership = Fabricate :membership, team: team, team_member: second_member, hours_per_month: 120, start_date: 1.day.ago, end_date: nil
        third_membership = Fabricate :membership, team: team, team_member: third_member, hours_per_month: 60, start_date: 1.day.ago, end_date: nil

        demand = Fabricate :demand, team: team, company: company
        first_assignment = Fabricate :item_assignment, demand: demand, membership: first_membership
        second_assignment = Fabricate :item_assignment, demand: demand, membership: second_membership
        third_assignment = Fabricate :item_assignment, demand: demand, membership: third_membership

        Fabricate :demand_effort, demand: demand, item_assignment: first_assignment, effort_value: 100, start_time_to_computation: Time.zone.now
        Fabricate :demand_effort, demand: demand, item_assignment: second_assignment, effort_value: 200, start_time_to_computation: Time.zone.now
        Fabricate :demand_effort, demand: demand, item_assignment: third_assignment, effort_value: 250, start_time_to_computation: Time.zone.now

        expect(first_slack_notifier).to receive(:post).once
        described_class.instance.notify_team_efficiency(first_slack_notifier, team, Time.zone.now.beginning_of_month, Time.zone.now.end_of_month, 'foo', 'bar')
      end
    end

    context 'with exceptions' do
      it 'logs the error' do
        allow(first_slack_notifier).to(receive(:post)).and_raise(Slack::Notifier::APIError)
        expect(Rails.logger).to(receive(:error))
        described_class.instance.notify_team_efficiency(first_slack_notifier, team, Time.zone.now.beginning_of_month, Time.zone.now.end_of_month, 'foo', 'bar')
      end
    end
  end
end
