# frozen_string_literal: true

RSpec.describe ProjectsSummaryData, type: :data_object do
  describe '#total_flow_pressure' do
    context 'having projects' do
      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      let!(:project) { Fabricate :project, start_date: 1.day.ago.beginning_of_day, end_date: 2.days.from_now.beginning_of_day, initial_scope: 0 }
      let!(:second_project) { Fabricate :project, start_date: 1.day.ago.beginning_of_day, end_date: 1.day.from_now.beginning_of_day, initial_scope: 0 }

      let!(:first_demand) { Fabricate :demand, project: project, demand_id: 'foo', created_date: Time.zone.yesterday.beginning_of_day, commitment_date: nil, end_date: nil }
      let!(:second_demand) { Fabricate :demand, project: project, demand_id: 'bar', created_date: 2.days.ago.beginning_of_day, commitment_date: nil, end_date: nil }

      let!(:third_demand) { Fabricate :demand, project: second_project, demand_id: 'xpto', created_date: 3.days.ago.beginning_of_day, commitment_date: nil, end_date: nil }

      it { expect(projects_summary.total_flow_pressure).to be_within(0.5).of(1.1) }

      it { expect(projects_summary.discovered_scope).to eq(discovered_after: [first_demand], discovered_before_project_starts: [third_demand, second_demand]) }
    end

    context 'having no projects' do
      subject(:projects_summary) { ProjectsSummaryData.new(Project.all) }

      it { expect(projects_summary.total_flow_pressure).to eq 0 }
      it { expect(projects_summary.discovered_scope).to eq({}) }
    end
  end
end
