# frozen_string_literal: true

RSpec.describe DemandBlock do
  context 'enums' do
    it { is_expected.to define_enum_for(:block_type).with_values(coding_needed: 0, specification_needed: 1, waiting_external_supplier: 2, customer_low_urgency: 3, integration_needed: 4, customer_unavailable: 5, other_demand_dependency: 6, external_dependency: 7, other_demand_priority: 8, waiting_for_code_review: 9, budget_approval: 10, waiting_deploy_window: 11, infrastructure: 12, scope_changed: 13, waiting_approval: 14, negotiating: 15) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:demand) }
    it { is_expected.to belong_to(:stage).optional }
    it { is_expected.to belong_to(:risk_review).optional }
    it { is_expected.to belong_to(:blocker).class_name(TeamMember).inverse_of(:demand_blocks) }
    it { is_expected.to belong_to(:unblocker).class_name(TeamMember).inverse_of(:demand_blocks).optional }
    it { is_expected.to have_many(:demand_block_notifications).class_name('Notifications::DemandBlockNotification').dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :block_time }
    it { is_expected.to validate_presence_of :block_type }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:blocker).with_prefix }
    it { is_expected.to delegate_method(:project_id).to(:demand) }
  end

  context 'callbacks' do
    describe '#before_save' do
      let(:stage) { Fabricate :stage }
      let(:demand) { Fabricate :demand }

      context 'with an unblock_time' do
        it 'computes the correct working time using the unblock value' do
          travel_to Time.zone.local(2021, 5, 26, 15, 46) do
            demand_block = Fabricate :demand_block, demand: demand, block_time: 1.day.ago
            demand_block.update(block_time: 2.days.ago, unblock_time: 1.day.ago)

            expect(demand_block.reload.block_working_time_duration).to eq 6
            expect(demand.reload.total_bloked_working_time).to eq 6
          end
        end
      end

      context 'when there is no unblock_time' do
        it 'uses current time' do
          travel_to Time.zone.local(2021, 5, 24, 15, 46) do
            demand_block = Fabricate :demand_block, demand: demand, block_time: 1.day.ago
            demand_block.update(block_time: 3.hours.ago, unblock_time: nil)
            expect(demand_block.reload.block_working_time_duration).to eq 3
            expect(demand.reload.total_bloked_working_time).to eq 6
          end
        end
      end

      context 'when there is no block_working_time_duration' do
        it 'uses current time' do
          travel_to Time.zone.local(2021, 5, 24, 15, 46) do
            demand_block = Fabricate :demand_block, demand: demand, block_time: 1.day.ago
            allow_any_instance_of(described_class).to(receive(:block_working_time_duration)).and_return(nil)
            demand_block.update(block_time: 3.hours.ago, unblock_time: nil)
            expect(demand_block.reload.block_working_time_duration).to be_nil
            expect(demand.reload.total_bloked_working_time).to eq 0.0
          end
        end
      end

      context 'when there is a demand current stage' do
        it 'associates the stage to the block' do
          demand_block = Fabricate :demand_block, demand: demand, block_time: 1.day.ago
          expect(demand).to(receive(:stage_at).once.and_return(stage))
          demand_block.update(block_time: Time.zone.now)
          expect(demand_block.reload.stage).to eq stage
        end
      end
    end
  end

  context 'scopes' do
    describe '.for_date_interval' do
      let!(:first_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: Time.zone.parse('2018-03-06 00:00') }
      let!(:second_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00') }
      let!(:out_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

      it { expect(described_class.for_date_interval(Time.zone.parse('2018-03-05 23:00'), Time.zone.parse('2018-03-06 13:00'))).to match_array [first_demand_block, second_demand_block] }
    end

    describe '.open' do
      let!(:first_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: nil }
      let!(:second_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: nil }
      let!(:third_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

      it { expect(described_class.open).to match_array [first_demand_block, second_demand_block] }
    end

    describe '.closed' do
      let!(:first_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: nil }
      let!(:second_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }
      let!(:third_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

      it { expect(described_class.closed).to match_array [second_demand_block, third_demand_block] }
    end

    describe '.for_active_projects' do
      let!(:first_project) { Fabricate :project, status: :executing }
      let!(:second_project) { Fabricate :project, status: :finished }
      let!(:first_demand) { Fabricate :demand, project: first_project }
      let!(:second_demand) { Fabricate :demand, project: second_project }

      let!(:first_demand_block) { Fabricate :demand_block, demand: first_demand }
      let!(:second_demand_block) { Fabricate :demand_block, demand: first_demand }
      let!(:third_demand_block) { Fabricate :demand_block, demand: second_demand }

      it { expect(described_class.for_active_projects).to match_array [first_demand_block, second_demand_block] }
    end

    describe '.for_inactive_projects' do
      let!(:first_project) { Fabricate :project, status: :executing }
      let!(:second_project) { Fabricate :project, status: :finished }
      let!(:first_demand) { Fabricate :demand, project: first_project }
      let!(:second_demand) { Fabricate :demand, project: second_project }

      let!(:first_demand_block) { Fabricate :demand_block, demand: first_demand }
      let!(:second_demand_block) { Fabricate :demand_block, demand: first_demand }
      let!(:third_demand_block) { Fabricate :demand_block, demand: second_demand }

      it { expect(described_class.for_inactive_projects).to match_array [third_demand_block] }
    end

    describe '.inactive' do
      let!(:first_demand_block) { Fabricate :demand_block, active: false }
      let!(:second_demand_block) { Fabricate :demand_block, active: false }
      let!(:third_demand_block) { Fabricate :demand_block, active: true }

      it { expect(described_class.inactive).to match_array [first_demand_block, second_demand_block] }
    end
  end

  describe '#activate!' do
    let(:demand_block) { Fabricate :demand_block, active: false }

    before { demand_block.activate! }

    it { expect(demand_block.active?).to be true }
  end

  describe '#deactivate!' do
    let(:demand_block) { Fabricate :demand_block, active: true }

    before { demand_block.deactivate! }

    it { expect(demand_block.active?).to be false }
  end

  describe '#total_blocked_time' do
    before { travel_to Time.zone.local(2019, 1, 10, 10, 0, 0) }

    context 'when it was unblocked' do
      let(:demand_block) { Fabricate :demand_block, active: true, block_time: 1.day.ago, unblock_time: Time.zone.now }

      it { expect(demand_block.total_blocked_time).to eq 1.day.to_f }
    end

    context 'when it still blocked' do
      let(:demand_block) { Fabricate :demand_block, active: true, block_time: 1.hour.ago, unblock_time: nil }

      it { expect(demand_block.total_blocked_time).to eq 3600.0 }
    end
  end

  describe '#to_hash' do
    let(:demand_block) { Fabricate :demand_block }

    it { expect(demand_block.to_hash).to eq(blocker_username: demand_block.blocker.name, block_time: demand_block.block_time, block_reason: demand_block.block_reason, unblock_time: demand_block.unblock_time) }
  end
end
