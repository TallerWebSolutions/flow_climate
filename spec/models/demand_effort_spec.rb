# frozen_string_literal: true

RSpec.describe DemandEffort, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :item_assignment }
    it { is_expected.to belong_to :demand_transition }
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :item_assignment }
    it { is_expected.to validate_presence_of :demand_transition }
    it { is_expected.to validate_presence_of :demand }
    it { is_expected.to validate_presence_of :management_percentage }
    it { is_expected.to validate_presence_of :stage_percentage }
    it { is_expected.to validate_presence_of :pairing_percentage }
    it { is_expected.to validate_presence_of :start_time_to_computation }
    it { is_expected.to validate_presence_of :finish_time_to_computation }
    it { is_expected.to validate_presence_of :effort_value }
    it { is_expected.to validate_presence_of :total_blocked }

    context 'uniqueness' do
      let(:demand) { Fabricate :demand }
      let(:demand_transition) { Fabricate :demand_transition, demand: demand }
      let(:item_assignment) { Fabricate :item_assignment, demand: demand }

      let!(:demand_effort) { Fabricate :demand_effort, demand: demand, item_assignment: item_assignment, demand_transition: demand_transition }

      it { expect(Fabricate.build(:demand_effort, demand: demand, item_assignment: item_assignment, demand_transition: demand_transition, start_time_to_computation: demand_effort.start_time_to_computation)).not_to be_valid }
      it { expect(Fabricate.build(:demand_effort, demand: demand, item_assignment: item_assignment, demand_transition: demand_transition)).to be_valid }
      it { expect(Fabricate.build(:demand_effort, demand: demand, demand_transition: demand_transition)).to be_valid }
      it { expect(Fabricate.build(:demand_effort, demand: demand, item_assignment: item_assignment)).to be_valid }
      it { expect(Fabricate.build(:demand_effort)).to be_valid }
    end
  end

  context 'scopes' do
    let(:upstream_stage) { Fabricate :stage, stage_stream: :upstream }
    let(:downstream_stage) { Fabricate :stage, stage_stream: :downstream }
    let(:demand) { Fabricate :demand }
    let(:upstream_transition) { Fabricate :demand_transition, stage: upstream_stage, demand: demand, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 15:51') }
    let(:other_upstream_transition) { Fabricate :demand_transition, stage: upstream_stage, demand: demand, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 15:51') }
    let(:downstream_transition) { Fabricate :demand_transition, stage: downstream_stage, demand: demand, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 15:51') }
    let(:other_downstream_transition) { Fabricate :demand_transition, stage: downstream_stage, demand: demand, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 15:51') }

    let(:development_membership) { Fabricate :membership, member_role: :developer }
    let(:other_development_membership) { Fabricate :membership, member_role: :developer }
    let(:designer_membership) { Fabricate :membership, member_role: :designer }
    let(:other_designer_membership) { Fabricate :membership, member_role: :designer }
    let(:management_membership) { Fabricate :membership, member_role: :management }
    let(:other_management_membership) { Fabricate :membership, member_role: :management }

    let(:development_assignment) { Fabricate :item_assignment, demand: demand, membership: development_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51') }
    let(:other_development_assignment) { Fabricate :item_assignment, demand: demand, membership: other_development_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51') }
    let(:designer_assignment) { Fabricate :item_assignment, demand: demand, membership: designer_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51') }
    let(:other_designer_assignment) { Fabricate :item_assignment, demand: demand, membership: other_designer_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51') }
    let(:management_assignment) { Fabricate :item_assignment, demand: demand, membership: management_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51') }

    let(:upstream_demand_effort) { Fabricate :demand_effort, demand: demand, demand_transition: upstream_transition, item_assignment: development_assignment }
    let(:other_upstream_demand_effort) { Fabricate :demand_effort, demand: demand, demand_transition: upstream_transition, item_assignment: other_development_assignment }

    let(:downstream_demand_effort) { Fabricate :demand_effort, demand: demand, demand_transition: downstream_transition, item_assignment: designer_assignment }
    let(:other_downstream_demand_effort) { Fabricate :demand_effort, demand: demand, demand_transition: downstream_transition, item_assignment: other_designer_assignment }

    describe '.upstream_efforts' do
      it { expect(described_class.upstream_efforts).to match_array [upstream_demand_effort, other_upstream_demand_effort] }
    end

    describe '.downstream_efforts' do
      it { expect(described_class.downstream_efforts).to match_array [downstream_demand_effort, other_downstream_demand_effort] }
    end

    describe '.developer_efforts' do
      it { expect(described_class.developer_efforts).to match_array [upstream_demand_effort, other_upstream_demand_effort] }
    end

    describe '.for_day' do
      it { expect(described_class.for_day(Date.new(2021, 5, 24))).to match_array described_class.all }
    end
  end
end
