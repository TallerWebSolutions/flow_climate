# frozen_string_literal: true

RSpec.describe ProjectsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }

  before { travel_to Time.zone.local(2018, 4, 13, 10, 0, 0) }

  describe '#search' do
    context 'with data' do
      it 'searches by arguments' do
        team = Fabricate :team, company: company

        first_project = Fabricate :project, company: company, team: team, name: 'Foo Bar', status: 'waiting', start_date: 3.days.ago, end_date: 2.days.ago
        second_project = Fabricate :project, company: company, team: team, name: 'Bar Foo', status: 'executing', start_date: 1.day.ago, end_date: 7.days.ago
        third_project = Fabricate :project, company: company, team: team, name: 'Xpto', status: 'finished', start_date: 5.days.ago, end_date: 4.days.ago
        fourth_project = Fabricate :project, company: company, team: team, name: 'Bar', status: 'waiting', start_date: 6.days.ago, end_date: 1.day.ago

        project_search = described_class.instance.search(company.id)

        expect(project_search.count).to eq 4
        expect(described_class.instance.search(company.id, project_status: 'waiting')).to match_array [first_project, fourth_project]
        expect(described_class.instance.search(company.id, project_status: 'finished')).to eq [third_project]
        expect(described_class.instance.search(company.id, project_name: 'Foo,Bar')).to eq [fourth_project, first_project, second_project]
        expect(described_class.instance.search(company.id, start_date: 1.day.ago, end_date: 4.days.ago)).to eq [second_project]
        expect(described_class.instance.search(company.id, end_date: 7.days.ago)).to eq [second_project]
        expect(described_class.instance.search(company.id, project_name: 'Bar Foo', project_status: 'executing', start_date: 1.day.ago)).to eq [second_project]
      end
    end
  end

  describe '#add_query_to_projects_in_status' do
    let(:other_customer) { Fabricate :customer }
    let(:team) { Fabricate :team, company: company }
    let!(:product) { Fabricate :product, company: company, customer: customer }

    context 'having data' do
      let!(:first_project) { Fabricate :project, company: company, customers: [customer], start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
      let!(:second_project) { Fabricate :project, company: company, customers: [customer], start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
      let!(:third_project) { Fabricate :project, company: company, customers: [customer], start_date: 2.months.from_now, end_date: 2.months.from_now, status: :waiting }
      let!(:fourth_project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }
      let!(:fifth_project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 1.week.from_now, end_date: 1.month.from_now, status: :finished }
      let!(:sixth_project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 3.months.from_now, end_date: 4.months.from_now, status: :cancelled }

      context 'passing status filter' do
        it { expect(described_class.instance.add_query_to_projects_in_status(Project.all, :maintenance)).to match_array [second_project, fourth_project] }
      end

      context 'passing no status filter' do
        it { expect(described_class.instance.add_query_to_projects_in_status(Project.all, 'all')).to match_array [first_project, second_project, third_project, fourth_project, fifth_project, sixth_project] }
      end
    end
  end

  describe '#finish_project' do
    let(:project) { Fabricate :project, company: company, status: :executing, start_date: 4.days.ago, end_date: 1.day.from_now }
    let(:other_project) { Fabricate :project, company: company, status: :executing }
    let(:previous_end_date) { 1.day.ago }
    let!(:consolidation_on_time) { Fabricate(:project_consolidation, project: project, consolidation_date: 1.day.ago) }
    let!(:consolidation_out_time) { Fabricate(:project_consolidation, project: project, consolidation_date: 1.day.from_now) }
    let!(:other_consolidation_out_time) { Fabricate(:project_consolidation, project: project, consolidation_date: 2.days.from_now) }

    context 'with ongoing demands' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: previous_end_date }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: nil }

      before { described_class.instance.finish_project(project) }

      it { expect(project.reload.status).to eq 'finished' }
      it { expect(project.reload.end_date).to eq Time.zone.today }
      it { expect(project.reload.project_consolidations.count).to eq 1 }

      it { expect(first_demand.reload.end_date).to eq previous_end_date }
      it { expect(second_demand.reload.end_date).not_to be_nil }
      it { expect(third_demand.reload.end_date).not_to be_nil }
    end

    context 'having no demands' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: previous_end_date }

      before { described_class.instance.finish_project(project) }

      it { expect(first_demand.reload.end_date).to eq previous_end_date }
      it { expect(project.reload.status).to eq 'finished' }
    end
  end

  describe '#projects_ending_after' do
    context 'having projects' do
      let(:project) { Fabricate :project, company: company, status: :executing, end_date: 2.days.ago }
      let(:other_project) { Fabricate :project, company: company, status: :executing, end_date: 1.day.ago }
      let(:out_project) { Fabricate :project, company: company, end_date: 4.days.ago }

      it { expect(described_class.instance.projects_ending_after(Project.all, 3.days.ago)).to match_array [project, other_project] }
    end

    context 'having no projects' do
      it { expect(described_class.instance.projects_ending_after(Project.all, 3.days.ago)).to eq [] }
    end
  end
end
