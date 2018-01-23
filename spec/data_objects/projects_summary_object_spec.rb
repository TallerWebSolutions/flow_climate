# frozen_string_literal: true

describe ProjectsSummaryObject, type: :data_object do
  describe '#percentage_hours_consumed' do
    context 'when the total hours is different of zero' do
      let!(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.percentage_hours_consumed).to eq((projects_summary.total_consumed_hours / projects_summary.total_hours) * 100) }
    end
    context 'when the total hours is zero' do
      let!(:project) { Fabricate :project, qty_hours: 0 }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project, qty_hours: 0 }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.percentage_hours_consumed).to eq 0 }
    end
  end
end
