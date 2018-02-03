# frozen_string_literal: true

RSpec.describe ProjectResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :project }
    it { is_expected.to have_many :demands }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :result_date }
    it { is_expected.to validate_presence_of :known_scope }
    it { is_expected.to validate_presence_of :qty_hours_downstream }
    it { is_expected.to validate_presence_of :qty_hours_upstream }
    it { is_expected.to validate_presence_of :throughput }
    it { is_expected.to validate_presence_of :qty_bugs_opened }
    it { is_expected.to validate_presence_of :qty_bugs_closed }
    it { is_expected.to validate_presence_of :qty_hours_bug }
  end

  context 'scopes' do
    describe '.for_week' do
      let(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:second_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:third_result) { Fabricate :project_result, result_date: 1.week.ago }
      it { expect(ProjectResult.for_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to match_array [first_result, second_result] }
    end
    describe '.until_week' do
      let(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:second_result) { Fabricate :project_result, result_date: 1.week.ago }
      let(:third_result) { Fabricate :project_result, result_date: 1.year.ago }
      let(:fourth_result) { Fabricate :project_result, result_date: Time.zone.today }
      it { expect(ProjectResult.until_week(1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [first_result, second_result, third_result] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team).with_prefix }
  end

  describe '#project_delivered_hours' do
    let(:result) { Fabricate :project_result }
    it { expect(result.project_delivered_hours).to eq result.qty_hours_upstream + result.qty_hours_downstream }
  end

  describe '#hours_per_demand' do
    context 'when the throughput is different of zero' do
      let(:result) { Fabricate :project_result }
      it { expect(result.hours_per_demand).to eq result.project_delivered_hours / result.throughput }
    end
    context 'when the throughput is zero' do
      let(:result) { Fabricate :project_result, throughput: 0 }
      it { expect(result.hours_per_demand).to eq 0 }
    end
  end

  describe '#define_automatic_project_params!' do
    context 'when the remaining days is different of zero' do
      let(:result) { Fabricate :project_result, known_scope: 20, throughput: 4 }
      before { result.define_automatic_project_params! }
      it { expect(result.reload.flow_pressure.to_f).to be_within(0.01).of(2.66) }
      it { expect(result.reload.remaining_days).to eq 6 }
    end
    context 'when the remaining days is zero' do
      let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: Time.zone.today }
      let(:result) { Fabricate :project_result, project: project }
      before { result.define_automatic_project_params! }
      it { expect(result.remaining_days).to eq 0 }
      it { expect(result.flow_pressure.to_f).to eq 0 }
    end
  end
end
