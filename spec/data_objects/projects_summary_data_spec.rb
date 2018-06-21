# frozen_string_literal: true

describe ProjectsSummaryData, type: :data_object do
  describe '#percentage_remaining_money' do
    context 'when the total hours is different of zero' do
      let!(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_money).to eq((projects_summary.total_remaining_money.to_f / projects_summary.total_value.to_f) * 100) }
    end
    context 'when the total_value is zero' do
      let!(:project) { Fabricate :project, value: 0 }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project, value: 0 }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_money).to eq 0 }
    end
  end

  describe '#percentage_remaining_days' do
    context 'when the total hours is different of zero' do
      let!(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_days).to eq((projects_summary.total_remaining_days.to_f / projects_summary.total_days.to_f) * 100) }
    end
    context 'when the start and end dates are in the same day' do
      let!(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today, value: 0 }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_days).to eq 100 }
    end
  end

  describe '#total_gap' do
    context 'when the total hours is different of zero' do
      let!(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.total_gap).to eq(projects_summary.total_last_week_scope - projects_summary.total_delivered_scope) }
    end
  end
end
