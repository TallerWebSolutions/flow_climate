# frozen_string_literal: true

RSpec.describe Slack::SlackNotificationService, type: :service do
  include ActionView::Helpers::NumberHelper

  before { travel_to Time.zone.local(2020, 3, 19, 10, 0, 0) }

  after { travel_back }

  let(:first_user) { Fabricate :user }

  let!(:company) { Fabricate :company, users: [first_user] }

  let(:team) { Fabricate :team, company: company, name: 'team' }
  let!(:team_member) { Fabricate :team_member, monthly_payment: 10_000, start_date: 5.weeks.ago, end_date: nil, name: 'team_member' }
  let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

  let!(:first_slack_config) { Fabricate :slack_configuration, team: team, info_type: :current_week_throughput, room_webhook: 'http://foo.com' }
  let!(:first_slack_notifier) { Slack::Notifier.new(first_slack_config.room_webhook) }

  context 'with data' do
    let!(:project) { Fabricate :project, team: team, company: company, status: :executing, name: 'project' }

    let!(:stage) { Fabricate :stage, company: company, stage_stream: :downstream, name: 'stage' }
    let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage, project: project, max_seconds_in_stage: 1.day }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10 }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, end_date: 3.weeks.ago }
    let!(:third_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, end_date: 3.weeks.ago }
    let!(:fifth_demand) { Fabricate :demand, team: team, project: project, demand_type: :chore, end_date: Time.zone.now }
    let!(:sixth_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, end_date: 2.weeks.ago }
    let!(:seventh_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, end_date: Time.zone.now }
    let!(:eighth_demand) { Fabricate :demand, team: team, project: project, demand_type: :chore, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300 }

    let!(:demand_transition) { Fabricate :demand_transition, demand: eighth_demand, stage: stage, last_time_in: 3.days.ago }

    describe '#notify_cmd' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Custo Médio por Demanda: *R$ 833,33* | Variação: *-61,90%* com relação à média das últimas 4 semanas (R$ 2.187,50) | CMD da últ. semana: *R$ 2.500,00*.").once
          described_class.instance.notify_cmd(first_slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))
          described_class.instance.notify_cmd(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_week_throughput' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Throughput na semana: *3 demanda(s)* | Variação: *200,00%* para a média das últimas 4 semanas (1.0).").once
          described_class.instance.notify_week_throughput(first_slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_week_throughput(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_last_week_delivered_demands_info' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Throughput: *1 demanda(s)* na semana passada.").once
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{first_demand.external_id}* #{first_demand.demand_title} | *Responsáveis:*  | *Custo pro Projeto:* #{number_to_currency(first_demand.cost_to_project)}").once

          described_class.instance.notify_last_week_delivered_demands_info(first_slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_last_week_delivered_demands_info(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_wip_demands' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Trabalho em progresso: 1 demanda(s).").once
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{eighth_demand.external_id}* #{eighth_demand.demand_title} | *Responsáveis:*  | *Custo pro Projeto:* #{number_to_currency(eighth_demand.cost_to_project)} | *Etapa atual:* #{stage.name} | *Tempo na Etapa:* 3 dias | *% Fluxo Concluído*: 100,00%").once

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
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.beyond_expected_title', team_name: team.name, beyond_expected_count: 1)).once
          expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{eighth_demand.external_id}* #{eighth_demand.demand_title} | *Etapa atual:* #{stage.name} | *Tempo na Etapa:* 3 dias").once

          described_class.instance.notify_beyond_expected_time_in_stage(first_slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
          allow(first_slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
          expect(Rails.logger).to(receive(:error))

          described_class.instance.notify_beyond_expected_time_in_stage(first_slack_notifier, team)
        end
      end
    end

    describe '#notify_failure_load' do
      context 'with no exceptions' do
        it 'calls slack notification method' do
          slack_notifier = instance_double('Slack::SlackNotifier')

          expect(Project).to receive(:running) { Project.all }
          expect(slack_notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.failure_load', team_name: team.name, failure_load: number_to_percentage(team.failure_load, precision: 2))).once
          expect(slack_notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.project_failure_load', team_name: team.name, project_name: project.name, failure_load: number_to_percentage(project.failure_load, precision: 2))).once

          described_class.instance.notify_failure_load(slack_notifier, team)
        end
      end

      context 'with exceptions' do
        it 'calls slack notification method' do
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
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Custo Médio por Demanda: *R$ 2.500,00* | Variação: *0,00%* com relação à média das últimas 4 semanas (R$ 2.500,00) | CMD da últ. semana: *R$ 2.500,00*.").once
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
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("> *#{team.name}* | Throughput: *0 demanda(s)* na semana passada.").once

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
      it 'calls slack notification method' do
        stage = Fabricate :stage, end_point: false
        demand = Fabricate :demand, team: team
        team_member = Fabricate :team_member
        Fabricate :slack_configuration, team: team, info_type: :demand_state_changed

        expect_any_instance_of(Slack::Notifier).to receive(:ping).with(/#{team_member.name}/)

        described_class.instance.notify_demand_state_changed(stage, demand, team_member)
      end
    end

    context 'with an end_point stage' do
      it 'calls slack notification method' do
        stage = Fabricate :stage, end_point: true
        demand = Fabricate :demand, team: team
        team_member = Fabricate :team_member
        Fabricate :slack_configuration, team: team, info_type: :demand_state_changed

        expect_any_instance_of(Slack::Notifier).to receive(:ping).with(/moneybag/)

        described_class.instance.notify_demand_state_changed(stage, demand, team_member)
      end
    end
  end

  describe '#notify_item_assigned' do
    it 'calls slack notification method' do
      demand = Fabricate :demand, team: team
      team_member = Fabricate :team_member
      membership = Fabricate :membership, team_member: team_member
      item_assignment = Fabricate :item_assignment, membership: membership, demand: demand
      Notifications::ItemAssignmentNotification.destroy_all

      Fabricate :slack_configuration, team: team, info_type: :item_assigned, active: true

      expect_any_instance_of(Slack::Notifier).to receive(:post)

      described_class.instance.notify_item_assigned(item_assignment)
      expect(Notifications::ItemAssignmentNotification.all.count).to eq 1
    end
  end

  describe '#notify_item_blocked' do
    context 'with blocked' do
      it 'calls slack notification method' do
        demand = Fabricate :demand, team: team
        demand_block = Fabricate :demand_block, demand: demand
        Notifications::DemandBlockNotification.destroy_all

        Fabricate :slack_configuration, team: team, info_type: :demand_blocked, active: true

        expect_any_instance_of(Slack::Notifier).to receive(:post)

        described_class.instance.notify_item_blocked(demand_block, 'http://foo.com')
        expect(Notifications::DemandBlockNotification.all.count).to eq 1
      end
    end

    context 'with unblocked' do
      it 'calls slack notification method' do
        demand = Fabricate :demand, team: team
        unblocker = Fabricate :team_member
        demand_block = Fabricate :demand_block, demand: demand, unblocker: unblocker, unblock_time: Time.zone.now
        Notifications::DemandBlockNotification.destroy_all

        Fabricate :slack_configuration, team: team, info_type: :demand_blocked, active: true

        expect_any_instance_of(Slack::Notifier).to receive(:post)

        described_class.instance.notify_item_blocked(demand_block, 'http://foo.com', 'unblocked')
        expect(Notifications::DemandBlockNotification.all.count).to eq 1
      end
    end
  end
end
