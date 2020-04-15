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

    let!(:fifth_demand) { Fabricate :demand, project: first_project, team: team, created_date: 4.days.ago, discarded_at: 3.days.ago }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, team: team, created_date: 2.days.ago, discarded_at: 2.days.ago }
    let!(:seventh_demand) { Fabricate :demand, project: first_project, team: team, created_date: 3.days.ago, discarded_at: Time.zone.now }

    let!(:eigth_demand) { Fabricate :demand, project: second_project, team: team, created_date: 4.days.ago, discarded_at: nil }
    let!(:nineth_demand) { Fabricate :demand, project: third_project, team: team, created_date: 4.days.ago, discarded_at: nil }

    it { expect(described_class.instance.known_scope_to_date(Demand.all.map(&:id), 2.days.ago).count).to eq 6 }
  end

  describe '#committed_demands_to_period' do
    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, commitment_date: 1.week.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago, discarded_at: Time.zone.today }

      it { expect(described_class.instance.committed_demands_to_period(Demand.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.committed_demands_to_period(Demand.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq [] }
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

      it { expect(described_class.instance.created_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.created_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to eq [] }
    end
  end

  describe '#throughput_to_period' do
    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.week.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago, discarded_at: Time.zone.today }

      it { expect(described_class.instance.throughput_to_period(Demand.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.throughput_to_period(Demand.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to eq [] }
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

      context 'with demands in progress' do
        it { expect(described_class.instance.grouped_by_effort_downstream_per_month(Project.all, 57.days.ago.to_date, Time.zone.today)).to eq([2018.0, 2.0] => 25.0, [2018.0, 3.0] => 186.0) }
        it { expect(described_class.instance.grouped_by_effort_downstream_per_month(Project.all, 24.days.ago.to_date, Time.zone.today)).to eq([2018.0, 3.0] => 186.0) }
      end
    end

    context 'with no demands' do
      it { expect(described_class.instance.grouped_by_effort_downstream_per_month(Project.all, 57.days.ago.to_date, Time.zone.today)).to eq({}) }
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

      it { expect(described_class.instance.demands_delivered_for_period_accumulated(Demand.all, 1.week.ago)).to match_array [third_demand, fifth_demand, sixth_demand] }
    end

    context 'with no demands' do
      it { expect(described_class.instance.demands_delivered_for_period_accumulated(Demand.all, 4.days.ago)).to eq [] }
    end
  end

  describe '#demands_delivered_grouped_by_projects_to_period' do
    let(:first_project) { Fabricate :project, start_date: 3.days.ago, end_date: 2.days.from_now }
    let(:second_project) { Fabricate :project, start_date: 2.days.ago, end_date: 1.day.from_now }

    let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }
    let!(:second_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.today }
    let!(:third_demand) { Fabricate :demand, project: second_project, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }
    let!(:fifth_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }

    it { expect(described_class.instance.demands_delivered_grouped_by_projects_to_period(Demand.all, 3.days.ago, 2.days.from_now)[first_project.name]).to match_array [first_demand, second_demand, fourth_demand, fifth_demand] }
    it { expect(described_class.instance.demands_delivered_grouped_by_projects_to_period(Demand.all, 3.days.ago, 2.days.from_now)[second_project.name]).to match_array [third_demand] }
  end

  shared_context 'demand data for filters' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:team) { Fabricate :team, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'flow climate' }
    let(:other_product) { Fabricate :product, customer: customer, name: 'flow control' }

    let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'command room' }
    let!(:other_portfolio_unit) { Fabricate :portfolio_unit, product: other_product, name: 'command center' }

    let(:project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], name: 'sbbrubles' }
    let(:other_project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], name: 'voyager' }

    let!(:first_demand) { Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: 2.days.ago, commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15 }
    let!(:second_demand) { Fabricate :demand, company: company, product: product, portfolio_unit: portfolio_unit, project: project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 0, effort_upstream: 0 }
    let!(:third_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: 5.days.ago, commitment_date: nil, end_date: 1.day.ago, effort_downstream: 0, effort_upstream: 10 }
    let!(:fourth_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: 10.days.ago, commitment_date: 5.days.ago, end_date: Time.zone.today, effort_downstream: 10, effort_upstream: 20 }

    let!(:fifth_demand) { Fabricate :demand, company: company, product: other_product, portfolio_unit: other_portfolio_unit, project: project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10 }
    let!(:sixth_demand) { Fabricate :demand, company: company, product: other_product, portfolio_unit: nil, project: project, demand_title: 'voyager sas', demand_type: :feature, class_of_service: :standard, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 10, effort_upstream: 10 }
    let!(:seventh_demand) { Fabricate :demand, company: company, product: other_product, project: other_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago, effort_downstream: 40, effort_upstream: 10 }
    let!(:eigth_demand) { Fabricate :demand, company: company, product: other_product, project: other_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60 }
  end

  describe '#filter_demands_by_text' do
    include_context 'demand data for filters'

    it { expect(described_class.instance.filter_demands_by_text(Demand.all, '')).to eq Demand.all }
    it { expect(described_class.instance.filter_demands_by_text(Demand.none, '')).to eq [] }
    it { expect(described_class.instance.filter_demands_by_text(Demand.all, 'climate')).to match_array [first_demand, second_demand, third_demand, fourth_demand] }
    it { expect(described_class.instance.filter_demands_by_text(Demand.all, 'flow')).to match_array Demand.all }
    it { expect(described_class.instance.filter_demands_by_text(Demand.all, 'hhh')).to eq [first_demand] }
    it { expect(described_class.instance.filter_demands_by_text(Demand.all, 'bar')).to match_array [second_demand, third_demand] }
    it { expect(described_class.instance.filter_demands_by_text(Demand.all, 'voyager')).to match_array [sixth_demand, seventh_demand, eigth_demand] }
    it { expect(described_class.instance.filter_demands_by_text(Demand.all, 'command')).to match_array [second_demand, fifth_demand] }
  end

  describe '#flow_status_query' do
    include_context 'demand data for filters'

    it { expect(described_class.instance.flow_status_query(Demand.all, '')).to eq Demand.all }
    it { expect(described_class.instance.flow_status_query(Demand.none, '')).to eq [] }
    it { expect(described_class.instance.flow_status_query(Demand.all, 'wip')).to match_array [second_demand, sixth_demand] }
    it { expect(described_class.instance.flow_status_query(Demand.all, 'delivered')).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand] }
    it { expect(described_class.instance.flow_status_query(Demand.all, 'not_started')).to match_array [first_demand, fifth_demand] }
  end

  describe '#demand_type_query' do
    include_context 'demand data for filters'

    it { expect(described_class.instance.demand_type_query(Demand.all, '')).to eq Demand.all }
    it { expect(described_class.instance.demand_type_query(Demand.none, '')).to eq [] }
    it { expect(described_class.instance.demand_type_query(Demand.all, 'bug')).to match_array [second_demand] }
  end

  describe '#class_of_service_query' do
    include_context 'demand data for filters'

    it { expect(described_class.instance.class_of_service_query(Demand.all, '')).to eq Demand.all }
    it { expect(described_class.instance.class_of_service_query(Demand.none, '')).to eq [] }
    it { expect(described_class.instance.class_of_service_query(Demand.all, 'expedite')).to match_array [second_demand, seventh_demand] }
  end

  pending '#bugs_opened_until_limit_date'
  pending '#bugs_closed_until_limit_date'
  pending '#remaining_backlog_to_date'
end
