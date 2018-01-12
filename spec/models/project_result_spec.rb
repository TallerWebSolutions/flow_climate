# frozen_string_literal: true

RSpec.describe ProjectResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :result_date }
    it { is_expected.to validate_presence_of :throughput }
    it { is_expected.to validate_presence_of :qty_bugs_opened }
    it { is_expected.to validate_presence_of :qty_bugs_closed }
    it { is_expected.to validate_presence_of :qty_hours_bug }
  end

  describe '#total_hours_consumed' do
    let(:result) { Fabricate :project_result }
    it { expect(result.total_hours_consumed).to eq result.qty_hours_upstream + result.qty_hours_downstream }
  end
end
