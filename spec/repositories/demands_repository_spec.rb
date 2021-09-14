# frozen_string_literal: true

RSpec.describe DemandsRepository, type: :repository do
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
      it 'returns the correct demands' do
        travel_to Time.zone.local(2020, 12, 12, 10, 0, 0) do
          first_demand = Fabricate :demand, project: first_project, commitment_date: 1.week.ago
          second_demand = Fabricate :demand, project: first_project, commitment_date: 1.week.ago
          third_demand = Fabricate :demand, project: second_project, commitment_date: 1.week.ago

          Fabricate :demand, project: first_project, commitment_date: 3.weeks.ago
          Fabricate :demand, project: first_project, commitment_date: 2.weeks.ago
          fourth_demand = Fabricate :demand, project: first_project, commitment_date: 1.week.ago, discarded_at: Time.zone.today

          expect(described_class.instance.committed_demands_to_period(Demand.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [first_demand, second_demand, third_demand, fourth_demand]
        end
      end
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

      it { expect(described_class.instance.created_to_projects_and_period(Project.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand, sixth_demand] }
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

      it { expect(described_class.instance.throughput_to_period(Demand.all, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand, sixth_demand] }
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

      it { expect(described_class.instance.throughput_to_products_team_and_period(Product.all, first_project.team, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to match_array [third_demand, fourth_demand, fifth_demand, sixth_demand] }
    end

    context 'with no data' do
      it { expect(described_class.instance.throughput_to_products_team_and_period(Product.all, first_project.team, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)).to eq [] }
    end
  end

  describe '#delivered_hours_in_month_for_projects' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }

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

      it { expect(described_class.instance.delivered_hours_in_month_for_projects(Project.all).to_f).to eq 72_918.0 }
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

      it { expect(described_class.instance.demands_delivered_for_period(Demand.all, 4.days.ago, Time.zone.now)).to match_array [first_demand, second_demand, eigth_demand] }
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
    let(:customer) { Fabricate :customer, company: company, name: 'customer' }
    let(:other_customer) { Fabricate :customer, company: company, name: 'other customer' }
    let(:team) { Fabricate :team, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'flow climate' }
    let(:other_product) { Fabricate :product, customer: customer, name: 'flow control' }

    let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'command room' }
    let!(:other_portfolio_unit) { Fabricate :portfolio_unit, product: other_product, name: 'command center' }

    let(:project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], name: 'sbbrubles' }
    let(:other_project) { Fabricate :project, company: company, customers: [customer], products: [product, other_product], name: 'voyager' }

    let!(:first_demand) { Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: 2.days.ago, commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15, demand_tags: %w[aaa ccc sbbrubles] }
    let!(:second_demand) { Fabricate :demand, company: company, product: product, portfolio_unit: portfolio_unit, project: project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto] }
    let!(:third_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: 5.days.ago, commitment_date: nil, end_date: 1.day.ago, effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc] }
    let!(:fourth_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: 10.days.ago, commitment_date: 5.days.ago, end_date: Time.zone.today, effort_downstream: 10, effort_upstream: 20, demand_tags: %w[xpto] }

    let!(:fifth_demand) { Fabricate :demand, company: company, product: other_product, portfolio_unit: other_portfolio_unit, project: project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10 }
    let!(:sixth_demand) { Fabricate :demand, company: company, product: other_product, portfolio_unit: nil, project: project, demand_title: 'voyager sas', demand_type: :feature, class_of_service: :standard, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 10, effort_upstream: 10 }
    let!(:seventh_demand) { Fabricate :demand, company: company, product: other_product, project: other_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago, effort_downstream: 40, effort_upstream: 10 }
    let!(:eigth_demand) { Fabricate :demand, company: company, product: other_product, project: other_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60 }

    let!(:ninth_demand) { Fabricate :demand, company: company, customer: other_customer, demand_title: 'customer test', demand_type: :bug, class_of_service: :fixed_date, created_date: 3.months.ago, commitment_date: 1.month.ago, end_date: 15.days.ago }
  end

  describe '#filter_demands_by_text' do
    it 'search for the demands using the text' do
      travel_to Time.zone.local(2020, 12, 8, 10, 0, 0) do
        company = Fabricate :company
        customer = Fabricate :customer, company: company, name: 'customer'
        other_customer = Fabricate :customer, company: company, name: 'other customer'
        product = Fabricate :product, customer: customer, name: 'flow climate'
        other_product = Fabricate :product, customer: customer, name: 'flow control'
        portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'command room'
        other_portfolio_unit = Fabricate :portfolio_unit, product: other_product, name: 'command center'
        project = Fabricate :project, company: company, customers: [customer], products: [product, other_product], name: 'sbbrubles'
        other_project = Fabricate :project, company: company, customers: [customer], products: [product, other_product], name: 'voyager'
        first_demand = Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: 2.days.ago, commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15, demand_tags: %w[aaa ccc sbbrubles]
        second_demand = Fabricate :demand, company: company, product: product, portfolio_unit: portfolio_unit, project: project, demand_title: 'foo cassini', demand_type: :bug, class_of_service: :expedite, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
        third_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'cassini foo', demand_type: :feature, class_of_service: :intangible, created_date: 5.days.ago, commitment_date: nil, end_date: 1.day.ago, effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
        fourth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: 10.days.ago, commitment_date: 5.days.ago, end_date: Time.zone.today, effort_downstream: 10, effort_upstream: 20, demand_tags: %w[xpto]
        fifth_demand = Fabricate :demand, company: company, product: other_product, portfolio_unit: other_portfolio_unit, project: project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10
        sixth_demand = Fabricate :demand, company: company, product: other_product, portfolio_unit: nil, project: project, demand_title: 'voyager sas', demand_type: :feature, class_of_service: :standard, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 10, effort_upstream: 10
        seventh_demand = Fabricate :demand, company: company, product: other_product, project: other_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago, effort_downstream: 40, effort_upstream: 10
        eigth_demand = Fabricate :demand, company: company, product: other_product, project: other_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60
        Fabricate :demand, company: company, customer: other_customer, demand_title: 'customer test', demand_type: :bug, class_of_service: :fixed_date, created_date: 3.months.ago, commitment_date: 1.month.ago, end_date: 15.days.ago

        expect(described_class.instance.filter_demands_by_text(Demand.all, '')).to eq Demand.all
        expect(described_class.instance.filter_demands_by_text(Demand.none, '')).to eq []
        expect(described_class.instance.filter_demands_by_text(Demand.all, 'climate')).to match_array [first_demand, second_demand, third_demand, fourth_demand]
        expect(described_class.instance.filter_demands_by_text(Demand.all, 'flow')).to match_array [first_demand, second_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand]
        expect(described_class.instance.filter_demands_by_text(Demand.all, 'hhh')).to eq [first_demand]
        expect(described_class.instance.filter_demands_by_text(Demand.all, 'cassini').map(&:external_id)).to match_array [second_demand, third_demand].map(&:external_id)
        expect(described_class.instance.filter_demands_by_text(Demand.all, 'voyager')).to match_array [sixth_demand, seventh_demand, eigth_demand]
        expect(described_class.instance.filter_demands_by_text(Demand.all, 'command')).to match_array [second_demand, fifth_demand]
      end
    end
  end

  describe '#demand_state_query' do
    it 'filters according to the query' do
      travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) do
        first_demand = Fabricate :demand, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: 2.days.ago, commitment_date: nil, end_date: nil
        second_demand = Fabricate :demand, demand_title: 'foo cassini', demand_type: :bug, class_of_service: :expedite, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil
        third_demand = Fabricate :demand, demand_title: 'cassini foo', demand_type: :feature, class_of_service: :intangible, created_date: 5.days.ago, commitment_date: nil, end_date: 1.day.ago
        fourth_demand = Fabricate :demand, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: 10.days.ago, commitment_date: 5.days.ago, end_date: Time.zone.today
        fifth_demand = Fabricate :demand, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil
        sixth_demand = Fabricate :demand, demand_title: 'voyager sas', demand_type: :feature, class_of_service: :standard, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil
        seventh_demand = Fabricate :demand, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago
        eigth_demand = Fabricate :demand, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today
        ninth_demand = Fabricate :demand, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today, discarded_at: Time.zone.now

        expect(described_class.instance.demand_state_query(Demand.all, '')).to eq Demand.all
        expect(described_class.instance.demand_state_query(Demand.none, '')).to eq []
        expect(described_class.instance.demand_state_query(Demand.all, 'wip')).to match_array [second_demand, sixth_demand]
        expect(described_class.instance.demand_state_query(Demand.all, 'delivered')).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand, ninth_demand]
        expect(described_class.instance.demand_state_query(Demand.all, 'not_committed')).to match_array [first_demand, fifth_demand]
        expect(described_class.instance.demand_state_query(Demand.all, %w[not_committed wip])).to match_array [first_demand, fifth_demand, second_demand, sixth_demand]
        expect(described_class.instance.demand_state_query(Demand.all, ['discarded'])).to eq [ninth_demand]
        expect(described_class.instance.demand_state_query(Demand.all, %w[discarded delivered])).to eq [ninth_demand]
        expect(described_class.instance.demand_state_query(Demand.all, %w[not_discarded delivered])).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand]
      end
    end
  end

  describe '#demand_type_query' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }

    include_context 'demand data for filters'

    it { expect(described_class.instance.demand_type_query(Demand.all, '')).to eq Demand.all }
    it { expect(described_class.instance.demand_type_query(Demand.none, '')).to eq [] }
    it { expect(described_class.instance.demand_type_query(Demand.all, 'bug')).to match_array [second_demand, ninth_demand] }
  end

  describe '#class_of_service_query' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }

    include_context 'demand data for filters'

    it { expect(described_class.instance.class_of_service_query(Demand.all, '')).to eq Demand.all }
    it { expect(described_class.instance.class_of_service_query(Demand.none, '')).to eq [] }
    it { expect(described_class.instance.class_of_service_query(Demand.all, 'expedite')).to match_array [second_demand, seventh_demand] }
  end

  describe '#team_query' do
    include_context 'demand data for filters'

    it 'returns the information' do
      travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) do
        company = Fabricate :company
        team = Fabricate :team, company: company
        other_team = Fabricate :team, company: company

        first_demand = Fabricate :demand, company: company, team: team, created_date: 2.days.ago, commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15, demand_tags: %w[aaa ccc sbbrubles]
        second_demand = Fabricate :demand, company: company, team: team, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
        third_demand = Fabricate :demand, company: company, team: team, created_date: 5.days.ago, commitment_date: nil, end_date: 1.day.ago, effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
        fourth_demand = Fabricate :demand, company: company, team: team, created_date: 10.days.ago, commitment_date: 5.days.ago, end_date: Time.zone.today, effort_downstream: 10, effort_upstream: 20, demand_tags: %w[xpto]

        fifth_demand = Fabricate :demand, company: company, team: other_team, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10
        sixth_demand = Fabricate :demand, company: company, team: other_team, demand_title: 'voyager sas', demand_type: :feature, class_of_service: :standard, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil, effort_downstream: 10, effort_upstream: 10
        seventh_demand = Fabricate :demand, company: company, team: other_team, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago, effort_downstream: 40, effort_upstream: 10
        eigth_demand = Fabricate :demand, company: company, team: other_team, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60

        expect(described_class.instance.team_query(Demand.all, team.id)).to match_array [first_demand, second_demand, third_demand, fourth_demand]
        expect(described_class.instance.team_query(Demand.all, other_team.id)).to match_array [fifth_demand, sixth_demand, seventh_demand, eigth_demand]
        expect(described_class.instance.team_query(Demand.none, other_team.id)).to eq []
        expect(described_class.instance.team_query(Demand.all, nil)).to match_array Demand.all
      end
    end
  end

  describe '#lead_time_zone_count' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }

    include_context 'demand data for filters'

    it { expect(described_class.instance.lead_time_zone_count(Demand.all, 86_400.0, nil)).to eq 2 }
    it { expect(described_class.instance.lead_time_zone_count(Demand.all, nil, 86_400)).to eq 2 }
    it { expect(described_class.instance.lead_time_zone_count(Demand.all, 50_400.0, 396_000.0)).to eq 2 }
  end

  describe '#wip_count' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }

    include_context 'demand data for filters'

    it { expect(described_class.instance.wip_count(Demand.all.map(&:id))).to eq 2 }
    it { expect(described_class.instance.wip_count(Demand.all.map(&:id), 2.weeks.ago)).to eq 0 }
  end

  pending '#bugs_opened_until_limit_date'
  pending '#bugs_closed_until_limit_date'
end
