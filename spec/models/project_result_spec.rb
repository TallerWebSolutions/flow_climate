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
      it { expect(ProjectResult.for_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to eq [first_result, second_result] }
    end
    describe '.until_week' do
      let(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:second_result) { Fabricate :project_result, result_date: 1.week.ago }
      let(:third_result) { Fabricate :project_result, result_date: Time.zone.today }
      it { expect(ProjectResult.until_week(1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq [first_result, second_result] }
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
    let(:result) { Fabricate :project_result }
    it { expect(result.hours_per_demand).to eq result.project_delivered_hours / result.throughput }
  end
end
