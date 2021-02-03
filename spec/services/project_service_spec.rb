# frozen_string_literal: true

RSpec.describe ProjectService, type: :service do
  let(:project) { Fabricate :project }

  describe '#risk_data_by_week' do
    it 'returns the weekly data for operational risk' do
      Fabricate :project_consolidation, consolidation_date: 2.weeks.ago, project: project, operational_risk: 0.875, team_based_operational_risk: 0.2, last_data_in_week: true
      Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: project, operational_risk: 0.875, team_based_operational_risk: 0.1, last_data_in_week: true

      expect(described_class.instance.risk_data_by_week(project)).to eq [87.5, 87.5]
    end
  end

  describe '#risk_data_by_week_team_data' do
    it 'returns the weekly data for operational risk' do
      Fabricate :project_consolidation, consolidation_date: 2.weeks.ago, project: project, operational_risk: 0.875, team_based_operational_risk: 0.2, last_data_in_week: true
      Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: project, operational_risk: 0.875, team_based_operational_risk: 0.1, last_data_in_week: true

      expect(described_class.instance.risk_data_by_week_team_data(project)).to eq [20, 10]
    end
  end
end
