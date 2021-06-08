# frozen_string_literal: true

RSpec.describe ProjectsSummaryData, type: :data_object do
  describe '#total_flow_pressure' do
    context 'with projects' do
      subject(:projects_summary) { described_class.new(Project.all) }

      let!(:project) { Fabricate :project, start_date: 1.week.ago, end_date: 2.weeks.from_now, initial_scope: 15 }
      let!(:second_project) { Fabricate :project, start_date: 3.days.ago, end_date: 1.week.from_now, initial_scope: 20 }

      let!(:first_demand) { Fabricate :demand, project: project, external_id: 'foo', created_date: Time.zone.yesterday, commitment_date: nil, end_date: nil }
      let!(:second_demand) { Fabricate :demand, project: project, external_id: 'bar', created_date: 2.weeks.ago, commitment_date: nil, end_date: nil }

      let!(:third_demand) { Fabricate :demand, project: second_project, external_id: 'xpto', created_date: 3.weeks.ago, commitment_date: nil, end_date: nil }

      it { expect(projects_summary.total_flow_pressure).to eq 3.5 }
      it { expect(projects_summary.discovered_scope).to match_array(discovered_after: [first_demand], discovered_before_project_starts: [third_demand, second_demand]) }
    end

    context 'with no projects' do
      subject(:projects_summary) { described_class.new(Project.all) }

      it { expect(projects_summary.total_flow_pressure).to eq 0 }
      it { expect(projects_summary.discovered_scope).to eq({}) }
    end
  end
end
