# frozen_string_literal: true

RSpec.describe Slack::SlackNotificationsJob, type: :active_job do
  include ActionView::Helpers::NumberHelper

  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      Slack::SlackNotificationsJob.perform_later
      expect(Slack::SlackNotificationsJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects to collect data' do
    before { travel_to Time.zone.local(2019, 6, 12, 10, 0, 0) }

    after { travel_back }

    let(:first_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user] }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 10_000, start_date: 5.weeks.ago, end_date: nil }

    let(:project) { Fabricate :project, team: team, company: company }

    let(:stage) { Fabricate :stage, company: company }
    let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage, project: project, max_seconds_in_stage: 1.day }

    let!(:first_slack_config) { Fabricate :slack_configuration, team: team, info_type: :average_demand_cost, room_webhook: 'http://foo.com' }
    let!(:second_slack_config) { Fabricate :slack_configuration, team: team, info_type: :current_week_throughput, room_webhook: 'http://foo.com' }
    let!(:third_slack_config) { Fabricate :slack_configuration, team: team, info_type: :last_week_delivered_demands_info, room_webhook: 'http://foo.com' }
    let!(:fourth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :demands_wip_info, room_webhook: 'http://foo.com' }
    let!(:fifth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :outdated_demands, room_webhook: 'http://foo.com' }

    let!(:first_demand) { Fabricate :demand, project: project, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10 }
    let!(:second_demand) { Fabricate :demand, project: project, end_date: 3.weeks.ago }
    let!(:third_demand) { Fabricate :demand, project: project, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, project: project, end_date: 3.weeks.ago }
    let!(:fifth_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
    let!(:sixth_demand) { Fabricate :demand, project: project, end_date: 2.weeks.ago }
    let!(:seventh_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
    let!(:eighth_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300 }

    let!(:demand_transition) { Fabricate :demand_transition, demand: eighth_demand, stage: stage, last_time_in: 3.days.ago }

    context 'with average_demand_cost notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{team.name}* | Custo Médio por Demanda: *R$ 833,33* | Última semana: R$ 2.500,00 | Variação: *-61,90%* com relação à média das últimas 4 semanas (R$ 2.187,50).").once
        Slack::SlackNotificationsJob.perform_now(first_slack_config, team)
      end
    end

    context 'with current_week_throughput notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{team.name}* | Throughput na semana: *3 demandas* | Variação: *200,00%* para a média das últimas 4 semanas (1.0).").once
        Slack::SlackNotificationsJob.perform_now(second_slack_config, team)
      end
    end

    context 'with last_week_delivered_demands_info notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{team.name}* | Throughput: *1 demandas* na semana passada.").once
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{first_demand.demand_id}* #{first_demand.demand_title} | *Responsáveis:*  | *Custo pro Projeto:* #{number_to_currency(first_demand.cost_to_project)}").once

        Slack::SlackNotificationsJob.perform_now(third_slack_config, team)
      end
    end

    context 'with demands_wip_info notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{team.name}* | Trabalho em progresso: 1 demanda(s).").once
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{eighth_demand.demand_id}* #{eighth_demand.demand_title} | *Responsáveis:*  | *Custo pro Projeto:* #{number_to_currency(eighth_demand.cost_to_project)} | *Etapa atual:* #{stage.name} | *Tempo na Etapa:* 3 dias | *% Fluxo Concluído*: 100,00%").once

        Slack::SlackNotificationsJob.perform_now(fourth_slack_config, team)
      end
    end

    context 'with outdated_demands notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with(I18n.t('slack_configurations.notifications.beyond_expected_title', team_name: team.name, beyond_expected_count: 1)).once
        expect_any_instance_of(Slack::Notifier).to receive(:ping).with("*#{eighth_demand.demand_id}* #{eighth_demand.demand_title} | *Etapa atual:* #{stage.name} | *Tempo na Etapa:* 3 dias").once

        Slack::SlackNotificationsJob.perform_now(fifth_slack_config, team)
      end
    end
  end
end
