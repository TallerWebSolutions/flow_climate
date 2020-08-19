# frozen-string-literal: true

RSpec.describe Consolidations::ReplenishingConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  describe '#average_team_throughput' do
    context 'with throughput data' do
      let(:consolidation) { Fabricate :replenishing_consolidation, team_throughput_data: [10, 20, 10] }

      it { expect(consolidation.average_team_throughput).to eq 13.333333333333334 }
    end
  end

  describe '#project_throughput_data_stddev' do
    context 'with throughput data' do
      let(:consolidation) { Fabricate :replenishing_consolidation, project_throughput_data: [10, 20, 10] }

      it { expect(consolidation.project_throughput_data_stddev).to eq 5.773502691896257 }
    end
  end

  describe '#project_throughput_data_mode' do
    context 'with throughput data' do
      let(:consolidation) { Fabricate :replenishing_consolidation, project_throughput_data: [10, 20, 10] }

      it { expect(consolidation.project_throughput_data_mode).to eq 10 }
    end
  end
end
