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

    context 'having project results' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_upstream: 0, qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

      it { expect(ProjectsRepository.instance.hours_consumed_per_month(company.projects, 2.months.ago.to_date)).to eq 90 }
    end

    context 'having no project results' do
      it { expect(ProjectsRepository.instance.hours_consumed_per_month(company.projects, 2.months.ago.to_date)).to eq 0 }
    end
  end

  describe '#hours_consumed_per_week' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 2.weeks.ago, end_date: 1.week.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, start_date: 2.weeks.ago, end_date: 1.week.from_now }

    context 'having project results' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.weeks.ago, qty_hours_upstream: 0, qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

      it { expect(ProjectsRepository.instance.hours_consumed_per_week(company.projects, 2.weeks.ago.to_date)).to eq 90 }
    end

    context 'having no project results' do
      it { expect(ProjectsRepository.instance.hours_consumed_per_week(company.projects, 2.weeks.ago.to_date)).to eq 0 }
    end
  end

  describe '#flow_pressure_to_month' do
    let!(:project) { Fabricate :project, customer: customer, initial_scope: 100, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, initial_scope: 50, start_date: 2.months.ago, end_date: 1.month.from_now }

    context 'having project results' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, flow_pressure: 2 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.month.ago, flow_pressure: 4 }

      it { expect(ProjectsRepository.instance.flow_pressure_to_month(company.projects, 2.months.ago.to_date)).to eq 2.0 }
    end

    context 'having no project results' do
      context 'if in the past, returns zero' do
        it { expect(ProjectsRepository.instance.flow_pressure_to_month(company.projects, 2.months.ago.to_date)).to eq 0 }
      end
      context 'if in the future, returns the future flow pressure to the project' do
        it { expect(ProjectsRepository.instance.flow_pressure_to_month(company.projects, 1.month.from_now.to_date)).to be_within(0.001).of(4.838) }
      end
    end
  end

  describe '#money_to_month' do
    let!(:project) { Fabricate :project, customer: customer, value: 100, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, value: 50, start_date: 2.months.ago, end_date: 1.month.from_now }
    context 'having projects in the month' do
      it { expect(ProjectsRepository.instance.money_to_month(company.projects, 2.months.ago.to_date).to_f).to eq 50.0 }
    end

    context 'having no projects in the month' do
      it { expect(ProjectsRepository.instance.money_to_month(company.projects, 3.months.ago.to_date)).to eq 0 }
    end
  end

  describe '#all_projects_for_team' do
    let(:other_customer) { Fabricate :customer }
    let(:team) { Fabricate :team, company: company }
    let!(:product) { Fabricate :product, customer: customer, team: team }

    let!(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
    let!(:second_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
    let!(:third_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :waiting }
    let!(:fourth_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }
    let!(:fifth_project) { Fabricate :project, customer: customer, product: product, start_date: 1.week.from_now, end_date: 1.month.from_now, status: :finished }
    let!(:sixth_project) { Fabricate :project, customer: customer, product: product, start_date: 3.months.from_now, end_date: 4.months.from_now, status: :cancelled }

    let!(:seventh_project) { Fabricate :project, customer: other_customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }
    let!(:eigth_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }

    let!(:first_project_result) { Fabricate :project_result, project: first_project, result_date: 2.days.ago, team: team }
    let!(:second_project_result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, team: team }
    let!(:third_project_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, team: team }

    it { expect(ProjectsRepository.instance.all_projects_for_team(team)).to match_array [first_project, second_project, third_project, fourth_project, fifth_project, sixth_project] }
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

  describe '#throughput_per_week' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 2.weeks.ago, end_date: 1.week.from_now, status: :executing }

    context 'having enough data from the project' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.parse('2018-04-05 22:00') }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.parse('2018-04-06 22:00') }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.parse('2018-03-30 22:00') }
      let!(:fourth_demand) { Fabricate :demand, project: project }

      it { expect(ProjectsRepository.instance.throughput_per_week([project])).to eq(Date.new(2018, 3, 26) => 1, Date.new(2018, 4, 2) => 2, Date.new(2018, 4, 9) => 0) }
    end
  end

  describe '#leadtime_per_week' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }

    let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.parse('2018-04-05 22:00'), leadtime: 2.0 }
    let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.parse('2018-04-06 22:00'), leadtime: 1.0 }
    let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.parse('2018-03-30 22:00'), leadtime: 5.0 }
    let!(:fourth_demand) { Fabricate :demand, project: project }

    it { expect(ProjectsRepository.instance.leadtime_per_week([project])).to eq(Date.new(2018, 4, 2) => 1.5, Date.new(2018, 4, 9) => 0.0) }
  end

  describe '#total_queue_time_for' do
    before { travel_back }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }

    let(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false }
    let(:second_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false }
    let(:fourth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, queue: false }

    let(:third_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: true }
    let(:fifth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: true }

    let(:demand) { Fabricate :demand, project: project }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-03-02T17:09:58-03:00' }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand, last_time_in: '2018-02-02T17:09:58-03:00', last_time_out: '2018-02-09T17:09:58-03:00' }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand, last_time_in: '2018-01-08T17:09:58-03:00', last_time_out: '2018-02-02T17:09:58-03:00' }

    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: demand, last_time_in: '2018-04-02T17:09:58-03:00', last_time_out: '2018-05-15T17:09:58-03:00' }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00' }

    it { expect(ProjectsRepository.instance.total_queue_time_for(Project.all)).to eq 1632.0 }
    it { expect(ProjectsRepository.instance.total_queue_time_for(Project.all, Date.new(2018, 4, 10))).to eq 600.0 }
  end

  describe '#hours_per_stage' do
    after { travel_back }

    context 'having transitions' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let(:other_project) { Fabricate :project, customer: customer }

      let(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'first_stage', queue: false, order: 2 }
      let(:second_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'second_stage', queue: false, order: 1 }
      let(:fourth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, name: 'fourth_stage', queue: false, order: 0 }

      let(:third_stage) { Fabricate :stage, company: company, projects: [other_project], stage_stream: :downstream, name: 'third_stage', queue: true, order: 4 }
      let(:fifth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'fifth_stage', queue: true, order: 3 }

      let(:sixth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'fifth_stage', end_point: true, order: 5 }

      let(:demand) { Fabricate :demand, project: project }
      let(:other_demand) { Fabricate :demand, project: other_project }

      let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-03-02T17:09:58-03:00' }
      let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand, last_time_in: '2018-02-02T17:09:58-03:00', last_time_out: '2018-02-09T17:09:58-03:00' }
      let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand, last_time_in: '2018-01-08T17:09:58-03:00', last_time_out: '2018-02-02T17:09:58-03:00' }

      let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: other_demand, last_time_in: '2018-04-02T17:09:58-03:00', last_time_out: '2018-05-15T17:09:58-03:00' }
      let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00' }

      let!(:sixth_transition) { Fabricate :demand_transition, stage: sixth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00' }

      it { expect(ProjectsRepository.instance.hours_per_stage(Project.all)).to eq([['fourth_stage', 0, 2_160_000.0], ['second_stage', 1, 604_800.0], ['first_stage', 2, 259_200.0], ['fifth_stage', 3, 2_160_000.0], ['third_stage', 4, 3_715_200.0]]) }
    end

    context 'having no transitions' do
      it { expect(ProjectsRepository.instance.hours_per_stage(Project.all)).to eq [] }
    end
  end

  describe '#total_touch_time_for' do
    before { travel_back }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }

    let(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false }
    let(:second_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false }
    let(:fourth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, queue: false }

    let(:third_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: true }
    let(:fifth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, queue: true }

    let(:demand) { Fabricate :demand, project: project }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-03-02T17:09:58-03:00' }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand, last_time_in: '2018-02-02T17:09:58-03:00', last_time_out: '2018-02-09T17:09:58-03:00' }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand, last_time_in: '2018-01-08T17:09:58-03:00', last_time_out: '2018-02-02T17:09:58-03:00' }

    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: demand, last_time_in: '2018-04-02T17:09:58-03:00', last_time_out: '2018-04-20T17:09:58-03:00' }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00' }

    it { expect(ProjectsRepository.instance.total_touch_time_for(Project.all)).to eq 240.0 }
    it { expect(ProjectsRepository.instance.total_touch_time_for(Project.all, Date.new(2018, 2, 16))).to eq 168.0 }
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
end
