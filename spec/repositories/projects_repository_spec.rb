# frozen_string_literal: true

RSpec.describe ProjectsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }

  before { travel_to Time.zone.local(2018, 4, 13, 10, 0, 0) }

  after { travel_back }

  describe '#active_projects_in_month' do
    let(:other_customer) { Fabricate :customer }

    let!(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
    let!(:second_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
    let!(:third_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :executing }
    let!(:fourth_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }

    let!(:fifth_project) { Fabricate :project, customer: customer, start_date: 1.week.from_now, end_date: 1.month.from_now, status: :executing }
    let!(:sixth_project) { Fabricate :project, customer: customer, start_date: 3.months.from_now, end_date: 4.months.from_now, status: :executing }
    let!(:seventh_project) { Fabricate :project, customer: other_customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }

    it { expect(ProjectsRepository.instance.active_projects_in_month(company.projects, 2.months.from_now)).to match_array [first_project, second_project, third_project, fourth_project] }
  end

  describe '#hours_consumed_per_month' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, start_date: 2.months.ago, end_date: 1.month.from_now }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, created_date: 3.months.ago.to_date, end_date: 2.months.ago.to_date, leadtime: 2 * 1.day, effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, project: other_project, commitment_date: nil, created_date: 4.months.ago.to_date, end_date: 2.months.ago, leadtime: 1 * 1.day, effort_upstream: 27, effort_downstream: 40 }

      it { expect(ProjectsRepository.instance.hours_consumed_per_month(company.projects, 2.months.ago.to_date)).to eq 0.82e2 }
    end

    context 'having no data' do
      it { expect(ProjectsRepository.instance.hours_consumed_per_month(company.projects, 2.months.ago.to_date)).to eq 0 }
    end
  end

  describe '#hours_consumed_per_week' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 2.weeks.ago, end_date: 1.week.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, start_date: 2.weeks.ago, end_date: 1.week.from_now }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, created_date: 3.months.ago.to_date, end_date: 2.weeks.ago.to_date, leadtime: 2 * 1.day, effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, project: other_project, commitment_date: nil, created_date: 4.months.ago.to_date, end_date: 2.weeks.ago, leadtime: 1 * 1.day, effort_upstream: 27, effort_downstream: 40 }

      it { expect(ProjectsRepository.instance.hours_consumed_per_week(company.projects, 2.weeks.ago.to_date)).to eq 0.82e2 }
    end

    context 'having no data' do
      it { expect(ProjectsRepository.instance.hours_consumed_per_week(company.projects, 2.weeks.ago.to_date)).to eq 0 }
    end
  end

  describe '#flow_pressure_to_month' do
    let!(:project) { Fabricate :project, customer: customer, initial_scope: 100, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, initial_scope: 50, start_date: 2.months.ago, end_date: 1.month.from_now }

    context 'having data' do
      it { expect(ProjectsRepository.instance.flow_pressure_to_month(company.projects, 2.months.ago.to_date)).to be_within(0.5).of(4.7) }
    end
  end

  describe '#money_to_month' do
    let!(:project) { Fabricate :project, customer: customer, value: 100, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, value: 50, start_date: 2.months.ago, end_date: 1.month.from_now }

    context 'having projects in the month' do
      it { expect(ProjectsRepository.instance.money_to_month(company.projects, 2.months.ago.to_date).to_f).to be_within(0.9).of(49.4) }
    end

    context 'having no projects in the month' do
      it { expect(ProjectsRepository.instance.money_to_month(company.projects, 3.months.ago.to_date)).to eq 0 }
    end
  end

  describe '#all_projects_for_team' do
    let(:other_customer) { Fabricate :customer }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:product) { Fabricate :product, customer: customer, team: team }

    let!(:first_project) { Fabricate :project, team: team, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
    let!(:second_project) { Fabricate :project, team: team, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
    let!(:third_project) { Fabricate :project, team: team, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :waiting }
    let!(:fourth_project) { Fabricate :project, team: other_team, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }
    let!(:fifth_project) { Fabricate :project, team: other_team, start_date: 1.week.from_now, end_date: 1.month.from_now, status: :finished }
    let!(:sixth_project) { Fabricate :project, team: other_team, start_date: 3.months.from_now, end_date: 4.months.from_now, status: :cancelled }

    let!(:seventh_project) { Fabricate :project, customer: other_customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }
    let!(:eigth_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }

    it { expect(ProjectsRepository.instance.all_projects_for_team(team)).to match_array [first_project, second_project, third_project] }
  end

  describe '#add_query_to_projects_in_status' do
    let(:other_customer) { Fabricate :customer }
    let(:team) { Fabricate :team, company: company }
    let!(:product) { Fabricate :product, customer: customer, team: team }

    context 'having data' do
      let!(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
      let!(:second_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
      let!(:third_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :waiting }
      let!(:fourth_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }
      let!(:fifth_project) { Fabricate :project, customer: customer, product: product, start_date: 1.week.from_now, end_date: 1.month.from_now, status: :finished }
      let!(:sixth_project) { Fabricate :project, customer: customer, product: product, start_date: 3.months.from_now, end_date: 4.months.from_now, status: :cancelled }

      context 'passing status filter' do
        it { expect(ProjectsRepository.instance.add_query_to_projects_in_status(Project.all, :maintenance)).to match_array [second_project, fourth_project] }
      end

      context 'passing no status filter' do
        it { expect(ProjectsRepository.instance.add_query_to_projects_in_status(Project.all, 'all')).to match_array [first_project, second_project, third_project, fourth_project, fifth_project, sixth_project] }
      end
    end
  end

  describe '#finish_project!' do
    let(:project) { Fabricate :project, status: :executing }
    let(:other_project) { Fabricate :project, status: :executing }
    let(:previous_end_date) { 1.day.ago }

    context 'having ongoing demands' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: previous_end_date }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: nil }

      before { ProjectsRepository.instance.finish_project!(project) }

      it { expect(project.reload.status).to eq 'finished' }
      it { expect(first_demand.reload.end_date).to eq previous_end_date }
      it { expect(second_demand.reload.end_date).not_to be_nil }
      it { expect(third_demand.reload.end_date).not_to be_nil }
    end

    context 'having no demands' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: previous_end_date }

      before { ProjectsRepository.instance.finish_project!(project) }

      it { expect(first_demand.reload.end_date).to eq previous_end_date }
      it { expect(project.reload.status).to eq 'finished' }
    end
  end

  describe '#projects_ending_after' do
    context 'having projects' do
      let(:project) { Fabricate :project, status: :executing, end_date: 2.days.ago }
      let(:other_project) { Fabricate :project, status: :executing, end_date: 1.day.ago }
      let(:out_project) { Fabricate :project, end_date: 4.days.ago }

      it { expect(ProjectsRepository.instance.projects_ending_after(Project.all, 3.days.ago)).to match_array [project, other_project] }
    end

    context 'having no projects' do
      it { expect(ProjectsRepository.instance.projects_ending_after(Project.all, 3.days.ago)).to eq [] }
    end
  end
end
