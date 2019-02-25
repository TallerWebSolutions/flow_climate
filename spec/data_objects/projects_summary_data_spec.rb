# frozen_string_literal: true

RSpec.describe ProjectsSummaryData, type: :data_object do
  describe '#total_flow_pressure' do
    context 'having projects' do
      let!(:project) { Fabricate :project }
      let!(:second_project) { Fabricate :project }

      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.total_flow_pressure).to eq 1.0 }
    end

    context 'having no projects' do
      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.total_flow_pressure).to eq 0 }
    end
  end
end
