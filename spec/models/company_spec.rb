# frozen_string_literal: true

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :users }
    it { is_expected.to have_many(:financial_informations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:customers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:products).through(:customers) }
    it { is_expected.to have_many(:projects).through(:customers) }
    it { is_expected.to have_many(:demands).through(:projects) }
    it { is_expected.to have_many(:teams).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:company_settings).dependent(:destroy) }
    it { is_expected.to have_many(:jira_accounts).dependent(:destroy) }
    it { is_expected.to have_many(:stages).dependent(:restrict_with_error) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :abbreviation }
  end

  describe '#add_user' do
    context 'when already has the user' do
      let(:user) { Fabricate :user }
      let!(:company) { Fabricate :company, users: [user] }
      before { company.add_user(user) }
      it { expect(company.users).to eq [user] }
    end
    context 'when does not have the user' do
      let(:user) { Fabricate :user }
      let!(:company) { Fabricate :company }
      before { company.add_user(user) }
      it { expect(company.users).to eq [user] }
    end
  end

  RSpec.shared_context 'demands with effort for company', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:product) { Fabricate :product, customer: customer }
    let!(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 100, hour_value: 10, monthly_payment: 1200, total_monthly_payment: 1300 }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing, qty_hours: 200 }
    let!(:other_active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing, qty_hours: 260 }
    let!(:other_customer_active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: product.customer, product: product, status: :executing, qty_hours: 300 }

    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting, qty_hours: 872 }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: active_project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: active_project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: active_project, stage: third_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: active_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: active_project, created_date: 2.weeks.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, project: active_project, created_date: 1.week.ago, end_date: 2.days.ago }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }

    let!(:third_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.today }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.today }

    let!(:fifth_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 5.weeks.ago }
  end

  describe '#active_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:other_customer_active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: other_product.customer, product: other_product, status: :executing }

    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    it { expect(company.active_projects_count).to eq 3 }
  end

  describe '#waiting_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:other_customer_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: other_product.customer, product: other_product, status: :waiting }

    let!(:executing_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    it { expect(company.waiting_projects_count).to eq 3 }
  end

  context '#projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customer: other_customer, product: other_product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }

    it { expect(company.projects_count).to eq 2 }
  end

  describe '#current_cost_per_hour' do
    context 'having finances' do
      before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }
      after { travel_back }

      let(:company) { Fabricate :company }
      let!(:first_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, expenses_total: 300 }
      let!(:second_finance) { Fabricate :financial_information, company: company, finances_date: 1.week.ago, expenses_total: 200 }
      let!(:third_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.from_now, expenses_total: 100 }

      include_context 'demands with effort for company'
      it { expect(company.current_cost_per_hour.to_f).to eq 1.2626262626262625 }

      pending 'having no efforts'
    end

    context 'having no finances' do
      let(:company) { Fabricate :company }
      it { expect(company.current_cost_per_hour).to eq 0 }
    end
  end

  describe '#current_hours_per_demand' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having finances' do
      include_context 'demands with effort for company'

      it { expect(company.current_hours_per_demand.to_f).to eq 158.4 }
    end

    context 'having no finances' do
      let(:company) { Fabricate :company }
      it { expect(company.current_hours_per_demand.to_f).to eq 0 }
    end
  end

  describe '#last_week_scope' do
    include_context 'demands with effort for company'

    it { expect(company.last_week_scope).to eq 182 }
  end

  describe '#avg_hours_per_demand' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    include_context 'demands with effort for company'

    it { expect(company.avg_hours_per_demand).to eq 52.800000000000004 }
  end

  describe '#consumed_hours_in_month' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    include_context 'demands with effort for company'

    it { expect(company.consumed_hours_in_month.to_f).to eq 158.4 }
  end

  describe '#throughput_in_month' do
    include_context 'demands with effort for company'

    it { expect(company.throughput_in_month.count).to eq 3 }
  end

  describe '#products_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let!(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    it { expect(company.products_count).to eq 2 }
  end

  RSpec.shared_context 'projects to company bulletin', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, customer: customer, status: :executing, initial_scope: 10, start_date: 2.weeks.ago.to_date, end_date: 4.days.from_now }
    let!(:second_project) { Fabricate :project, customer: other_customer, status: :executing, initial_scope: 40, start_date: 2.weeks.ago.to_date, end_date: 5.days.from_now }
    let!(:third_project) { Fabricate :project, customer: other_customer, status: :executing, initial_scope: 30, start_date: 2.weeks.ago.to_date, end_date: 6.days.from_now }

    let!(:waiting_project) { Fabricate :project, customer: customer, status: :waiting, initial_scope: 5, start_date: 2.weeks.ago.to_date, end_date: 3.days.from_now }

    let!(:first_demand) { Fabricate :demand, project: first_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: second_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :feature }
    let!(:third_demand) { Fabricate :demand, project: third_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :feature }
    let!(:fifth_demand) { Fabricate :demand, project: second_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
    let!(:sixth_demand) { Fabricate :demand, project: third_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
  end

  describe '#top_three_flow_pressure' do
    include_context 'projects to company bulletin'
    it { expect(company.top_three_flow_pressure).to eq [second_project, third_project, first_project] }
  end

  describe '#top_three_throughput' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    include_context 'projects to company bulletin'
    it { expect(company.top_three_throughput).to eq [third_project, second_project, first_project] }
  end

  describe '#next_starting_project' do
    include_context 'projects to company bulletin'
    it { expect(company.next_starting_project).to eq waiting_project }
  end

  describe '#next_finishing_project' do
    include_context 'projects to company bulletin'
    it { expect(company.next_finishing_project).to eq first_project }
  end

  describe '#demands_delivered_last_week' do
    let(:company) { Fabricate :company }
    it 'calls the repository' do
      expect(DemandsRepository.instance).to receive(:demands_for_company_and_week).once
      company.demands_delivered_last_week
    end
  end

  describe '#total_active_hours' do
    context 'having data' do
      include_context 'demands with effort for company'
      it { expect(company.total_active_hours).to eq 0.1632e4 }
    end
    context 'having no data' do
      let(:company) { Fabricate :company }
      it { expect(company.total_active_hours).to eq 0 }
    end
  end

  describe '#total_active_consumed_hours' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort for company'
      it { expect(company.total_active_consumed_hours.to_f).to eq 158.4 }
    end

    context 'having no data' do
      let(:company) { Fabricate :company }
      it { expect(company.total_active_consumed_hours).to eq 0 }
    end
  end

  describe '#total_available_hours' do
    context 'having data' do
      include_context 'demands with effort for company'
      it { expect(company.total_available_hours).to eq 100 }
    end

    context 'having no data' do
      let(:company) { Fabricate :company }
      it { expect(company.total_active_consumed_hours).to eq 0 }
    end
  end
end
