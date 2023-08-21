# frozen_string_literal: true

RSpec.describe Slack::SlackNotificationsJob, type: :active_job do
  include ActionView::Helpers::NumberHelper

  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  context 'with projects to collect data' do
    before { travel_to Time.zone.local(2019, 6, 12, 10, 0, 0) }

    let(:first_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user] }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, monthly_payment: 10_000, start_date: 5.weeks.ago, end_date: nil }
    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

    let(:project) { Fabricate :project, team: team, company: company }

    let(:stage) { Fabricate :stage, company: company }
    let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage, project: project, max_seconds_in_stage: 1.day }

    let!(:first_slack_config) { Fabricate :slack_configuration, team: team, info_type: :average_demand_cost, room_webhook: 'http://foo.com' }
    let!(:second_slack_config) { Fabricate :slack_configuration, team: team, info_type: :current_week_throughput, room_webhook: 'http://foo.com' }
    let!(:third_slack_config) { Fabricate :slack_configuration, team: team, info_type: :last_week_delivered_demands_info, room_webhook: 'http://foo.com' }
    let!(:fourth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :demands_wip_info, room_webhook: 'http://foo.com' }
    let!(:fifth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :outdated_demands, room_webhook: 'http://foo.com' }
    let!(:sixth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :failure_load, room_webhook: 'http://foo.com' }
    let!(:seventh_slack_config) { Fabricate :slack_configuration, team: team, info_type: :team_review, room_webhook: 'http://foo.com' }
    let!(:eighth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :weekly_team_efficiency, room_webhook: 'http://foo.com' }
    let!(:nineth_slack_config) { Fabricate :slack_configuration, team: team, info_type: :monthly_team_efficiency, room_webhook: 'http://foo.com' }

    context 'with average_demand_cost notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_cmd).once
        described_class.perform_now(first_slack_config, team)
      end
    end

    context 'with current_week_throughput notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_week_throughput).once
        described_class.perform_now(second_slack_config, team)
      end
    end

    context 'with last_week_delivered_demands_info notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_last_week_delivered_demands_info).once

        described_class.perform_now(third_slack_config, team)
      end
    end

    context 'with demands_wip_info notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_wip_demands).once

        described_class.perform_now(fourth_slack_config, team)
      end
    end

    context 'with outdated_demands notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_beyond_expected_time_in_stage).once

        described_class.perform_now(fifth_slack_config, team)
      end
    end

    context 'with failure_load notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_failure_load).once

        described_class.perform_now(sixth_slack_config, team)
      end
    end

    context 'with notify_team_review notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_team_review).once

        described_class.perform_now(seventh_slack_config, team)
      end
    end

    context 'with weekly_team_efficiency notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_week_team_efficiency).once

        described_class.perform_now(eighth_slack_config, team)
      end
    end

    context 'with monthly_team_efficiency notification' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_month_team_efficiency).once

        described_class.perform_now(nineth_slack_config, team)
      end
    end
  end
end
