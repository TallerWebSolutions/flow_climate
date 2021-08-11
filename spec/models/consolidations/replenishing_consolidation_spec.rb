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

  describe '#increased_pressure?' do
    it 'returns false when the previous pressure is less than the current pressure' do
      first_consolidation = Fabricate :replenishing_consolidation, flow_pressure: 10, consolidation_date: 2.days.ago
      second_consolidation = Fabricate :replenishing_consolidation, flow_pressure: 15, consolidation_date: 1.day.ago
      third_consolidation = Fabricate :replenishing_consolidation, flow_pressure: 8, consolidation_date: Time.zone.today

      expect(first_consolidation.increased_pressure?).to be false
      expect(second_consolidation.increased_pressure?).to be true
      expect(third_consolidation.increased_pressure?).to be false
    end
  end

  describe '#increased_leadtime_80?' do
    it 'returns false when the previous lead time p80 is less than the current pressure' do
      first_consolidation = Fabricate :replenishing_consolidation, leadtime_80: 10, consolidation_date: 2.days.ago
      second_consolidation = Fabricate :replenishing_consolidation, leadtime_80: 15, consolidation_date: 1.day.ago
      third_consolidation = Fabricate :replenishing_consolidation, leadtime_80: 8, consolidation_date: Time.zone.today

      expect(first_consolidation.increased_leadtime_80?).to be false
      expect(second_consolidation.increased_leadtime_80?).to be true
      expect(third_consolidation.increased_leadtime_80?).to be false
    end
  end

  describe '#increased_work_in_progress?' do
    it 'returns false when the previous WiP is less than the current pressure' do
      first_consolidation = Fabricate :replenishing_consolidation, work_in_progress: 10, consolidation_date: 2.days.ago
      second_consolidation = Fabricate :replenishing_consolidation, work_in_progress: 15, consolidation_date: 1.day.ago
      third_consolidation = Fabricate :replenishing_consolidation, work_in_progress: 8, consolidation_date: Time.zone.today

      expect(first_consolidation.increased_work_in_progress?).to be false
      expect(second_consolidation.increased_work_in_progress?).to be true
      expect(third_consolidation.increased_work_in_progress?).to be false
    end
  end

  describe '#increased_avg_throughtput?' do
    it 'returns false when the previous pressure is less than the current pressure' do
      first_consolidation = Fabricate :replenishing_consolidation, team_throughput_data: [2, 3], consolidation_date: 2.days.ago
      second_consolidation = Fabricate :replenishing_consolidation, team_throughput_data: [5, 6], consolidation_date: 1.day.ago
      third_consolidation = Fabricate :replenishing_consolidation, team_throughput_data: [0, 1], consolidation_date: Time.zone.today

      expect(first_consolidation.increased_avg_throughtput?).to be false
      expect(second_consolidation.increased_avg_throughtput?).to be true
      expect(third_consolidation.increased_avg_throughtput?).to be false
    end
  end

  describe '#increased_team_lead_time?' do
    it 'returns false when the previous lead time is less than the current pressure' do
      first_consolidation = Fabricate :replenishing_consolidation, team_lead_time: 10, consolidation_date: 2.days.ago
      second_consolidation = Fabricate :replenishing_consolidation, team_lead_time: 15, consolidation_date: 1.day.ago
      third_consolidation = Fabricate :replenishing_consolidation, team_lead_time: 8, consolidation_date: Time.zone.today

      expect(first_consolidation.increased_team_lead_time?).to be false
      expect(second_consolidation.increased_team_lead_time?).to be true
      expect(third_consolidation.increased_team_lead_time?).to be false
    end
  end
end
