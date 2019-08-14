# frozen_string_literal: true

RSpec.describe DemandsRepository, type: :repository do
  before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }

  after { travel_back }

  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:other_customer) { Fabricate :customer }

  let(:team) { Fabricate :team, company: company }

  let(:product) { Fabricate :product, customer: customer }
  let(:other_product) { Fabricate :product, customer: customer }

  let(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], team: team, start_date: 4.weeks.ago }
  let(:second_project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], team: team, start_date: 3.weeks.ago }
  let(:third_project) { Fabricate :project, customers: [other_customer], products: [product, other_product], team: team, end_date: 1.week.from_now }
  let(:fourth_project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], team: team, end_date: 1.week.from_now }

  describe '#known_scope_to_date' do
    let!(:first_demand) { Fabricate :demand, project: first_project, team: team, created_date: 3.days.ago, discarded_at: nil }
    let!(:second_demand) { Fabricate :demand, project: first_project, team: team, created_date: 2.days.ago, discarded_at: nil }
    let!(:third_demand) { Fabricate :demand, project: first_project, team: team, created_date: 2.days.ago, discarded_at: nil }
    let!(:fourth_demand) { Fabricate :demand, project: first_project, team: team, created_date: 1.day.ago, discarded_at: nil }

    let!(:fifth_demand) { Fabricate :demand, project: first_project, team: team, created_date: 2.days.ago, discarded_at: 3.days.ago }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, team: team, created_date: 2.days.ago, discarded_at: 2.days.ago }
    let!(:seventh_demand) { Fabricate :demand, project: first_project, team: team, created_date: 3.days.ago, discarded_at: Time.zone.now }

    let!(:eigth_demand) { Fabricate :demand, project: second_project, team: team, created_date: 4.days.ago, discarded_at: nil }
    let!(:nineth_demand) { Fabricate :demand, project: third_project, team: team, created_date: 4.days.ago, discarded_at: nil }

    let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

    it { expect(described_class.instance.known_scope_to_date([first_project, second_project], 2.days.ago)).to eq 65 }
  end

  describe '#demands_created_before_date_to_projects' do
    subject(:query_return) { described_class.instance.demands_created_before_date_to_projects([first_project]) }

    let!(:first_demand) { Fabricate :demand, project: first_project, demand_id: 'first_demand', created_date: 4.days.ago, end_date: 3.days.ago, discarded_at: nil }
    let!(:second_demand) { Fabricate :demand, project: first_project, demand_id: 'second_demand', created_date: 3.days.ago, end_date: 2.days.ago, discarded_at: nil }
    let!(:third_demand) { Fabricate :demand, project: first_project, demand_id: 'third_demand', created_date: 2.days.ago, end_date: nil, discarded_at: nil }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, demand_id: 'fourth_demand', created_date: 1.day.ago, end_date: 1.day.ago, discarded_at: nil }
    let!(:fifth_demand) { Fabricate :demand, project: second_project, demand_id: 'fifth_demand', created_date: 2.days.ago, end_date: 2.days.ago, discarded_at: nil }

    let!(:sixth_demand) { Fabricate :demand, project: first_project, demand_id: 'sixth_demand', discarded_at: Time.zone.today }

    let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

    it { expect(query_return.map(&:id)).to match_array [first_demand.id, second_demand.id, third_demand.id] }
  end

  describe '#committed_demands_by_project_and_week' do
    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, commitment_date: 1.week.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago, discarded_at: Time.zone.today }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.committed_demands_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.committed_demands_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq [] }
    end
  end

  describe '#created_to_projects_and_period' do
    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, created_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, created_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, created_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, created_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, created_date: 1.week.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, created_date: 1.week.ago, discarded_at: Time.zone.today }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.created_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.created_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to eq [] }
    end
  end

  describe '#throughput_to_projects_and_period' do
    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.week.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago, discarded_at: Time.zone.today }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.throughput_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.throughput_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to eq [] }
    end
  end

  describe '#throughput_to_products_team_and_period' do
    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, product: product, team: team, end_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, product: product, team: team, end_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, product: other_product, team: team, end_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, product: product, team: team, end_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, product: product, team: team, end_date: 1.week.ago }

      let!(:sixth_demand) { Fabricate :demand, end_date: 1.week.ago, team: team, discarded_at: Time.zone.today }

      let!(:first_epic) { Fabricate :demand, project: first_project, product: product, team: team, artifact_type: :epic }

      it { expect(described_class.instance.throughput_to_products_team_and_period(Product.all, first_project.team, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.throughput_to_products_team_and_period(Product.all, first_project.team, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to eq [] }
    end
  end

  describe '#effort_upstream_grouped_by_month' do
    let(:project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: 60.days.ago, end_date: 57.days.ago, effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: 58.days.ago, end_date: 55.days.ago, effort_upstream: 12, effort_downstream: 20 }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: 30.days.ago, end_date: 24.days.ago, effort_upstream: 27, effort_downstream: 40 }
      let!(:fourth_demand) { Fabricate :demand, project: project, commitment_date: 29.days.ago, end_date: 22.days.ago, effort_upstream: 80, effort_downstream: 34 }
      let!(:fifth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 7.days.ago, effort_upstream: 56, effort_downstream: 25 }
      let!(:sixth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 5.days.ago, effort_upstream: 32, effort_downstream: 87 }
      let!(:seventh_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: nil, effort_upstream: 32, effort_downstream: 87 }
      let!(:eigth_demand) { Fabricate :demand, project: project, commitment_date: 29.days.ago, end_date: 22.days.ago, effort_upstream: 80, effort_downstream: 34, discarded_at: Time.zone.today }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.effort_upstream_grouped_by_month(Project.all, 57.days.ago.to_date, Time.zone.today)).to eq([2018.0, 2.0] => 22.0, [2018.0, 3.0] => 195.0) }
      it { expect(described_class.instance.effort_upstream_grouped_by_month(Project.all, 24.days.ago.to_date, Time.zone.today)).to eq([2018.0, 3.0] => 195.0) }
    end

    context 'with no demands' do
      it { expect(described_class.instance.effort_upstream_grouped_by_month(Project.all, 57.days.ago.to_date, Time.zone.today)).to eq({}) }
    end
  end

  describe '#grouped_by_effort_downstream_per_month' do
    let(:project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: 60.days.ago, end_date: 57.days.ago, effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: 58.days.ago, end_date: 55.days.ago, effort_upstream: 12, effort_downstream: 20 }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: 30.days.ago, end_date: 24.days.ago, effort_upstream: 27, effort_downstream: 40 }
      let!(:fourth_demand) { Fabricate :demand, project: project, commitment_date: 29.days.ago, end_date: 22.days.ago, effort_upstream: 80, effort_downstream: 34 }
      let!(:fifth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 7.days.ago, effort_upstream: 56, effort_downstream: 25 }
      let!(:sixth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 5.days.ago, effort_upstream: 32, effort_downstream: 87 }
      let!(:seventh_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: nil, effort_upstream: 32, effort_downstream: 87 }
      let!(:eigth_demand) { Fabricate :demand, project: project, commitment_date: 29.days.ago, end_date: 22.days.ago, effort_upstream: 80, effort_downstream: 34, discarded_at: Time.zone.today }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      context 'with demands in progress' do
        it { expect(described_class.instance.grouped_by_effort_downstream_per_month(Project.all, 57.days.ago.to_date, Time.zone.today)).to eq([2018.0, 2.0] => 25.0, [2018.0, 3.0] => 186.0) }
        it { expect(described_class.instance.grouped_by_effort_downstream_per_month(Project.all, 24.days.ago.to_date, Time.zone.today)).to eq([2018.0, 3.0] => 186.0) }
      end
    end

    context 'with no demands' do
      it { expect(described_class.instance.grouped_by_effort_downstream_per_month(Project.all, 57.days.ago.to_date, Time.zone.today)).to eq({}) }
    end
  end

  describe '#delivered_until_date_to_projects_in_upstream' do
    let(:first_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:second_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:third_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let(:first_stage) { Fabricate :stage, company: company, projects: [first_project, second_project], integration_pipe_id: '123', order: 0, stage_stream: :upstream }
      let(:second_stage) { Fabricate :stage, company: company, projects: [first_project, second_project], integration_pipe_id: '123', order: 1, stage_stream: :upstream, end_point: true }

      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 2.days.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.day.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 2.days.ago, end_date: 2.days.ago }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: 3.days.ago, end_date: Time.zone.now }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      context 'upstream' do
        it { expect(described_class.instance.delivered_until_date_to_projects_in_stream(Project.all, 'upstream')).to match_array [first_demand, second_demand, third_demand] }
        it { expect(described_class.instance.delivered_until_date_to_projects_in_stream(Project.all, 'upstream', 1.day.ago)).to match_array [first_demand, second_demand] }
      end

      context 'downstream' do
        it { expect(described_class.instance.delivered_until_date_to_projects_in_stream(Project.all, 'downstream')).to match_array [fourth_demand, fifth_demand] }
        it { expect(described_class.instance.delivered_until_date_to_projects_in_stream(Project.all, 'downstream', 1.day.ago)).to eq [fourth_demand] }
      end
    end

    context 'with no demands' do
      it { expect(described_class.instance.delivered_until_date_to_projects_in_stream(Project.all, 'upstream')).to eq [] }
    end
  end

  describe '#delivered_hours_in_month_for_projects' do
    let(:first_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:second_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:third_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 4.days.ago, effort_upstream: 558, effort_downstream: 929 }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.day.ago, effort_upstream: 932, effort_downstream: 112 }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: 3.weeks.ago, effort_upstream: 536, effort_downstream: 643 }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: nil, effort_upstream: 210, effort_downstream: 432 }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.week.ago, effort_upstream: 1100, effort_downstream: 230 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: nil, end_date: 1.month.ago, effort_upstream: 100, effort_downstream: 23 }
      let!(:seventh_demand) { Fabricate :demand, project: third_project, commitment_date: Time.zone.today, end_date: Time.zone.tomorrow, effort_upstream: 120, effort_downstream: 723 }

      let!(:eigth_demand) { Fabricate :demand, project: second_project, commitment_date: Time.zone.today, discarded_at: Time.zone.today, effort_upstream: 54_321, effort_downstream: 15_223 }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.delivered_hours_in_month_for_projects(Project.all).to_f).to eq 3374.0 }
      it { expect(described_class.instance.delivered_hours_in_month_for_projects(Project.all, Date.new(2018, 3, 1)).to_f).to eq 2632.0 }
    end

    context 'with no demands' do
      it { expect(described_class.instance.delivered_hours_in_month_for_projects(Project.all)).to eq 0 }
    end
  end

  describe '#demands_delivered_for_period' do
    let(:first_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:second_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:third_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 4.days.ago, effort_upstream: 558, effort_downstream: 929 }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.day.ago, effort_upstream: 932, effort_downstream: 112 }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: 3.weeks.ago, effort_upstream: 536, effort_downstream: 643 }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: nil, effort_upstream: 210, effort_downstream: 432 }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.week.ago, effort_upstream: 1100, effort_downstream: 230 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: nil, end_date: 1.month.ago, effort_upstream: 100, effort_downstream: 23 }
      let!(:seventh_demand) { Fabricate :demand, project: third_project, commitment_date: Time.zone.today, end_date: Time.zone.tomorrow, effort_upstream: 120, effort_downstream: 723 }

      let!(:eigth_demand) { Fabricate :demand, project: second_project, commitment_date: Time.zone.today, discarded_at: Time.zone.today, effort_upstream: 54_321, effort_downstream: 15_223 }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.demands_delivered_for_period(Demand.all, 4.days.ago, Time.zone.now)).to match_array [first_demand, second_demand] }
    end

    context 'with no demands' do
      it { expect(described_class.instance.demands_delivered_for_period(Demand.all, 4.days.ago, Time.zone.now)).to eq [] }
    end
  end

  describe '#demands_delivered_for_period_accumulated' do
    let(:first_project) { Fabricate :project, customers: [customer], start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:second_project) { Fabricate :project, customers: [customer], start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:third_project) { Fabricate :project, customers: [customer], start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 4.days.ago, effort_upstream: 558, effort_downstream: 929 }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.day.ago, effort_upstream: 932, effort_downstream: 112 }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: 3.weeks.ago, effort_upstream: 536, effort_downstream: 643 }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: nil, effort_upstream: 210, effort_downstream: 432 }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.week.ago, effort_upstream: 1100, effort_downstream: 230 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: nil, end_date: 1.month.ago, effort_upstream: 100, effort_downstream: 23 }
      let!(:seventh_demand) { Fabricate :demand, project: third_project, commitment_date: Time.zone.today, end_date: Time.zone.tomorrow, effort_upstream: 120, effort_downstream: 723 }

      let!(:eigth_demand) { Fabricate :demand, project: second_project, commitment_date: Time.zone.today, discarded_at: Time.zone.today, effort_upstream: 54_321, effort_downstream: 15_223 }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      it { expect(described_class.instance.demands_delivered_for_period_accumulated(Demand.all, 1.week.ago)).to match_array [third_demand, fifth_demand, sixth_demand] }
    end

    context 'with no demands' do
      it { expect(described_class.instance.demands_delivered_for_period_accumulated(Demand.all, 4.days.ago)).to eq [] }
    end
  end

  describe '#cumulative_flow_for_date' do
    let(:first_stage) { Fabricate :stage, company: company, projects: [first_project, second_project], name: 'first_stage', integration_pipe_id: '123', order: 0, stage_stream: :downstream }
    let(:second_stage) { Fabricate :stage, company: company, projects: [first_project, second_project], name: 'second_stage', integration_pipe_id: '123', order: 1, stage_stream: :downstream, end_point: true }

    let(:first_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:second_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }
    let(:third_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'with demands' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 4.days.ago, effort_upstream: 558, effort_downstream: 929 }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.day.ago, effort_upstream: 932, effort_downstream: 112 }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: 3.weeks.ago, effort_upstream: 536, effort_downstream: 643 }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, end_date: nil, effort_upstream: 210, effort_downstream: 432 }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: 1.week.ago, effort_upstream: 1100, effort_downstream: 230 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: nil, end_date: 1.month.ago, effort_upstream: 100, effort_downstream: 23 }

      let!(:seventh_demand) { Fabricate :demand, project: second_project, commitment_date: Time.zone.today, discarded_at: Time.zone.today, effort_upstream: 54_321, effort_downstream: 15_223 }
      let!(:eigth_demand) { Fabricate :demand, project: second_project, commitment_date: Time.zone.today, discarded_at: 2.weeks.ago, effort_upstream: 54_321, effort_downstream: 15_223 }

      let!(:first_epic) { Fabricate :demand, project: first_project, artifact_type: :epic }

      let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-02-28T17:09:58-03:00' }
      let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: '2018-03-01T17:09:58-03:00', last_time_out: '2018-03-01T17:09:58-03:00' }
      let!(:third_transition) { Fabricate :demand_transition, stage: first_stage, demand: third_demand, last_time_in: '2018-03-04T17:09:58-03:00', last_time_out: nil }
      let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: fourth_demand, last_time_in: '2018-03-10T17:09:58-03:00', last_time_out: nil }
      let!(:fifth_transition) { Fabricate :demand_transition, stage: first_stage, demand: fifth_demand, last_time_in: '2018-03-15T17:09:58-03:00', last_time_out: nil }
      let!(:sixth_transition) { Fabricate :demand_transition, stage: first_stage, demand: seventh_demand, last_time_in: '2018-03-01T17:09:58-03:00', last_time_out: nil }
      let!(:seventh_transition) { Fabricate :demand_transition, stage: first_stage, demand: eigth_demand, last_time_in: '2018-04-01T17:09:58-03:00', last_time_out: nil }

      it { expect(described_class.instance.cumulative_flow_for_date(Demand.all.map(&:id), Date.new(2018, 2, 27), 1.week.ago, :downstream)).to eq(first_stage.name => 4, second_stage.name => 2) }
    end

    context 'with no demands' do
      it { expect(described_class.instance.cumulative_flow_for_date(Demand.all.map(&:id), 2.months.ago, 1.week.ago, :downstream)).to eq({}) }
    end
  end

  describe '#total_time_for' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customers: [customer] }

    let(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false, order: 1 }
    let(:second_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false, order: 2 }
    let(:fourth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, queue: false, order: 3 }

    let(:third_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: true, order: 4 }
    let(:fifth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: true, order: 5, end_point: true }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }
    let!(:upstream_demand) { Fabricate :demand, project: project, commitment_date: nil }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: demand, start_time: '2018-01-08T17:09:58-03:00', finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: other_demand, start_time: '2018-01-08T17:09:58-03:00', finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: upstream_demand, start_time: '2018-01-08T17:09:58-03:00', finish_time: nil }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-03-02T17:09:58-03:00' }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand, last_time_in: '2018-02-02T17:09:58-03:00', last_time_out: '2018-02-09T17:09:58-03:00' }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand, last_time_in: '2018-01-08T17:09:58-03:00', last_time_out: '2018-02-02T17:09:58-03:00' }

    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: demand, last_time_in: '2018-04-02T17:09:58-03:00', last_time_out: '2018-05-15T17:09:58-03:00' }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00' }

    let!(:sixth_transition) { Fabricate :demand_transition, stage: first_stage, demand: other_demand, last_time_in: '2018-03-17T17:09:58-03:00', last_time_out: '2018-03-18T17:09:58-03:00' }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: second_stage, demand: other_demand, last_time_in: '2018-03-19T17:09:58-03:00', last_time_out: '2018-03-20T17:09:58-03:00' }
    let!(:eigth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: other_demand, last_time_in: '2018-03-21T17:09:58-03:00', last_time_out: '2018-03-23T17:09:58-03:00' }

    let!(:ninth_transition) { Fabricate :demand_transition, stage: third_stage, demand: other_demand, last_time_in: '2018-03-24T17:09:58-03:00', last_time_out: '2018-03-25T17:09:58-03:00' }
    let!(:tenth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: other_demand, last_time_in: '2018-03-26T17:09:58-03:00', last_time_out: '2018-03-27T17:09:58-03:00' }

    let!(:eleventh_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: upstream_demand, last_time_in: '2018-03-26T17:09:58-03:00', last_time_out: '2018-10-10T17:09:58-03:00' }
    let!(:twefth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: upstream_demand, last_time_in: '2018-03-26T17:09:58-03:00', last_time_out: '2018-10-10T17:09:58-03:00' }

    it { expect(described_class.instance.total_time_for(Project.all, 'total_queue_time', 'week')).to eq([10, 2018] => 233_402.0, [13, 2018] => 1.day.to_f) }
    it { expect(described_class.instance.total_time_for(Project.all, 'total_touch_time', 'week')).to eq([10, 2018] => 864_000.0, [13, 2018] => 172_800.0) }
    it { expect(described_class.instance.total_time_for(Project.all, 'total_queue_time', 'month')).to eq([3, 2018] => 319_802.0) }
    it { expect(described_class.instance.total_time_for(Project.all, 'total_touch_time', 'month')).to eq([3, 2018] => 1_036_800.0) }
    it { expect(described_class.instance.total_time_for(Project.all, 'total_queue_time', 'day')).to eq('2018-03-08' => 233_402.0, '2018-03-26' => 86_400.0) }
    it { expect(described_class.instance.total_time_for(Project.all, 'total_touch_time', 'day')).to eq('2018-03-08' => 864_000.0, '2018-03-26' => 172_800.0) }
  end

  describe '#demands_delivered_grouped_by_projects_to_period' do
    let(:first_project) { Fabricate :project, start_date: 3.days.ago, end_date: 2.days.from_now }
    let(:second_project) { Fabricate :project, start_date: 2.days.ago, end_date: 1.day.from_now }

    let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }
    let!(:second_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.today }
    let!(:third_demand) { Fabricate :demand, project: second_project, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }
    let!(:fifth_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }

    it { expect(described_class.instance.demands_delivered_grouped_by_projects_to_period([first_project, second_project], 3.days.ago, 2.days.from_now)[first_project.name]).to match_array [first_demand, second_demand, fourth_demand, fifth_demand] }
    it { expect(described_class.instance.demands_delivered_grouped_by_projects_to_period([first_project, second_project], 3.days.ago, 2.days.from_now)[second_project.name]).to match_array [third_demand] }
  end

  pending '#bugs_opened_until_limit_date'
  pending '#bugs_closed_until_limit_date'
  pending '#remaining_backlog_to_date'
  pending '#discarded_demands_to_projects'
end
