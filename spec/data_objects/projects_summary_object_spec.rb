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

      it { expect(projects_summary.percentage_hours_consumed).to eq((projects_summary.total_consumed_hours.to_f / projects_summary.total_hours.to_f) * 100) }
    end
    context 'when the total hours is zero' do
      let!(:project) { Fabricate :project, qty_hours: 0 }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.percentage_hours_consumed).to eq 0 }
    end
  end

  describe '#percentage_remaining_money' do
    context 'when the total hours is different of zero' do
      let!(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_money).to eq((projects_summary.total_remaining_money.to_f / projects_summary.total_value.to_f) * 100) }
    end
    context 'when the total_value is zero' do
      let!(:project) { Fabricate :project, value: 0 }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project, value: 0 }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

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

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_days).to eq((projects_summary.total_remaining_days.to_f / projects_summary.total_days.to_f) * 100) }
    end
    context 'when the total_days is zero' do
      let!(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today, value: 0 }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.percentage_remaining_days).to eq 0 }
    end
  end

  describe '#total_gap' do
    context 'when the total hours is different of zero' do
      let!(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:other_project_result) { Fabricate :project_result, project: project }

      let!(:second_project) { Fabricate :project }
      let!(:second_project_result) { Fabricate :project_result, project: second_project }

      subject(:projects_summary) { ProjectsSummaryObject.new(Project.all) }

      it { expect(projects_summary.total_gap).to eq(projects_summary.total_current_scope - projects_summary.total_delivered_scope) }
    end
  end
end
