# frozen_string_literal: true

RSpec.describe Slack::DemandSlackNotificationsJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  describe '#perform' do
    let(:first_user) { Fabricate :user }
    let!(:company) { Fabricate :company, users: [first_user] }
    let(:team) { Fabricate :team, company: company }
    let(:demand) { Fabricate :demand, team: team }

    context 'with blocks' do
      context 'when it has notified everything' do
        it 'never calls slack notification method' do
          demand_block = Fabricate :demand_block, demand: demand
          Fabricate :demand_block_notification, demand_block: demand_block, block_state: 'blocked'
          Fabricate :demand_block_notification, demand_block: demand_block, block_state: 'unblocked'

          expect_any_instance_of(Slack::SlackNotificationService).not_to receive(:notify_item_blocked)
          described_class.perform_now(team)
        end
      end

      context 'when it has notified blocked' do
        it 'calls slack notification method once' do
          Fabricate :demand_block, demand: demand

          expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_item_blocked).once
          described_class.perform_now(team)
        end
      end

      context 'when it was never notified and it was unblocked' do
        it 'calls slack notification method twice' do
          Fabricate :demand_block, demand: demand, block_time: 1.day.ago, unblock_time: Time.zone.now

          expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_item_blocked).twice
          described_class.perform_now(team)
        end
      end

      context 'when it was never notified and it was not unblocked' do
        it 'calls slack notification method twice' do
          Fabricate :demand_block, demand: demand, block_time: 1.day.ago, unblock_time: nil

          expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_item_blocked).once
          described_class.perform_now(team)
        end
      end
    end

    context 'with transitions' do
      context 'when it has notified' do
        it 'calls the notification method for the transitions not notified yet' do
          Fabricate :demand_transition, demand: demand, transition_notified: false
          Fabricate :demand_transition, demand: demand, transition_notified: false
          Fabricate :demand_transition, demand: demand, transition_notified: true

          expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_demand_state_changed).twice
          described_class.perform_now(team)
        end
      end
    end

    context 'with assignments' do
      context 'when it has notified' do
        it 'calls the notification method for the assignments not notified yet' do
          Fabricate :item_assignment, demand: demand, assignment_notified: false
          Fabricate :item_assignment, demand: demand, assignment_notified: false
          Fabricate :item_assignment, demand: demand, assignment_notified: true

          expect_any_instance_of(Slack::SlackNotificationService).to receive(:notify_item_assigned).twice
          described_class.perform_now(team)
        end
      end
    end
  end
end
