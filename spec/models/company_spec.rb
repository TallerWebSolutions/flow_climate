# frozen_string_literal: true

RSpec.describe Company, type: :model do
  before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }

  after { travel_back }

  context 'associations' do
    it { is_expected.to have_many(:users).through(:user_company_roles) }
    it { is_expected.to have_many(:user_company_roles) }
    it { is_expected.to have_many(:financial_informations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:customers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:products).through(:customers) }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:jira_project_configs).through(:projects) }
    it { is_expected.to have_many(:demands) }
    it { is_expected.to have_many(:team_members) }
    it { is_expected.to have_many(:memberships).through(:team_members) }
    it { is_expected.to have_many(:teams).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:company_settings).dependent(:destroy) }
    it { is_expected.to have_many(:jira_accounts).dependent(:destroy) }
    it { is_expected.to have_many(:stages).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:team_resources).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :abbreviation }
  end

  context 'uniqueness' do
    let!(:company) { Fabricate :company, abbreviation: 'xpTo' }
    let(:same_company) { Fabricate.build :company, abbreviation: 'xpto' }
    let(:other_same_company) { Fabricate.build :company, abbreviation: 'xpTo foo' }

    it { expect(other_same_company).to be_valid }
    it { expect(same_company).not_to be_valid }
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
    let!(:team_member) { Fabricate :team_member, monthly_payment: 1200, end_date: nil }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 1.month.ago, end_date: nil }

    let!(:active_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing, qty_hours: 200 }
    let!(:other_active_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing, qty_hours: 260 }
    let!(:other_customer_active_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [product.customer], products: [product], status: :executing, qty_hours: 300 }

    let!(:waiting_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting, qty_hours: 872 }
    let!(:finished_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false, integration_pipe_id: 1, order: 0 }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true, integration_pipe_id: 1, order: 1 }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true, integration_pipe_id: 1, order: 2 }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: active_project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: active_project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: active_project, stage: third_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: active_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: active_project, created_date: 2.weeks.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, project: active_project, created_date: 1.week.ago, end_date: 2.days.ago }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: team_member, start_time: 1.month.ago, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: team_member, start_time: 1.month.ago, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: team_member, start_time: 7.weeks.ago, finish_time: nil }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }

    let!(:third_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.today }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.today }

    let!(:fifth_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 5.weeks.ago }
  end

  describe '#active_projects_count' do
    include_context 'demands with effort for company'

    it { expect(company.active_projects_count).to eq 4 }
  end

  describe '#running_projects_count' do
    include_context 'demands with effort for company'

    it { expect(company.running_projects_count).to eq 3 }
  end

  describe '#generate_token' do
    let(:company) { Fabricate :company }

    it { expect(company.api_token).not_to be_nil }
  end

  describe '#waiting_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:waiting_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:other_customer_waiting_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [other_product.customer], products: [other_product], status: :waiting }

    let!(:executing_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing }
    let!(:finished_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, company: company, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    it { expect(company.waiting_projects_count).to eq 3 }
  end

  describe '#projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product], status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, company: company, customers: [customer], products: [product], status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customers: [other_customer], products: [other_product], status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }

    it { expect(company.projects.count).to eq 2 }
  end

  describe '#current_cost_per_hour' do
    context 'with finances' do
      let(:company) { Fabricate :company }
      let!(:first_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, expenses_total: 300 }
      let!(:second_finance) { Fabricate :financial_information, company: company, finances_date: 1.week.ago, expenses_total: 200 }
      let!(:third_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.from_now, expenses_total: 100 }

      include_context 'demands with effort for company'
      it { expect(company.current_cost_per_hour.to_f).to eq 0.946969696969697 }

      pending 'with no efforts'
    end

    context 'with no finances' do
      let(:company) { Fabricate :company }

      it { expect(company.current_cost_per_hour).to eq 0 }
    end
  end

  describe '#current_hours_per_demand' do
    context 'with finances' do
      include_context 'demands with effort for company'

      it { expect(company.current_hours_per_demand.to_f).to eq 35.199999999999996 }
    end

    context 'with no finances' do
      let(:company) { Fabricate :company }

      it { expect(company.current_hours_per_demand.to_f).to eq 0 }
    end
  end

  describe '#last_week_scope' do
    include_context 'demands with effort for company'

    it { expect(company.last_week_scope).to eq 183 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'demands with effort for company'

    it { expect(company.avg_hours_per_demand).to eq 35.199999999999996 }
  end

  describe '#consumed_hours_in_month' do
    include_context 'demands with effort for company'

    it { expect(company.consumed_hours_in_month.to_f).to eq 105.6 }
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

    let!(:first_project) { Fabricate :project, company: company, customers: [customer], name: 'first_project', status: :executing, initial_scope: 10, start_date: 2.weeks.ago.to_date, end_date: 4.days.from_now }
    let!(:second_project) { Fabricate :project, company: company, customers: [other_customer], name: 'second_project', status: :executing, initial_scope: 40, start_date: 2.weeks.ago.to_date, end_date: 5.days.from_now }
    let!(:third_project) { Fabricate :project, company: company, customers: [other_customer], name: 'third_project', status: :executing, initial_scope: 30, start_date: 2.weeks.ago.to_date, end_date: 6.days.from_now }

    let!(:waiting_project) { Fabricate :project, company: company, customers: [customer], status: :waiting, initial_scope: 5, start_date: 2.weeks.ago.to_date, end_date: 3.days.from_now }

    let!(:first_demand) { Fabricate :demand, project: first_project, created_date: 2.weeks.ago, end_date: 9.days.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: second_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :feature }
    let!(:third_demand) { Fabricate :demand, project: third_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :feature }
    let!(:fifth_demand) { Fabricate :demand, project: second_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
    let!(:sixth_demand) { Fabricate :demand, project: third_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
    let!(:seventh_demand) { Fabricate :demand, project: third_project, created_date: 1.week.ago, end_date: 1.day.ago, demand_type: :feature }
    let!(:eigth_demand) { Fabricate :demand, project: third_project, created_date: 1.week.ago, end_date: 2.days.ago, demand_type: :feature }
  end

  describe '#top_three_flow_pressure' do
    include_context 'projects to company bulletin'
    it { expect(company.top_three_flow_pressure).to eq [second_project, third_project, first_project] }
  end

  describe '#top_three_throughput' do
    include_context 'projects to company bulletin'
    it { expect(company.top_three_throughput(1.day.ago)).to eq [third_project, second_project, first_project] }
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

    context 'with projects' do
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company, customers: [customer] }

      it 'calls the repository' do
        expect(DemandsRepository.instance).to receive(:throughput_to_period).once
        company.demands_delivered_last_week
      end
    end

    context 'with no projects' do
      it 'calls the repository' do
        expect(DemandsRepository.instance).not_to receive(:throughput_to_period)
        expect(company.demands_delivered_last_week).to eq []
      end
    end
  end

  describe '#total_active_hours' do
    context 'with data' do
      include_context 'demands with effort for company'
      it { expect(company.total_active_hours).to eq 0.1632e4 }
    end

    context 'with no data' do
      let(:company) { Fabricate :company }

      it { expect(company.total_active_hours).to eq 0 }
    end
  end

  describe '#total_active_consumed_hours' do
    context 'with data' do
      include_context 'demands with effort for company'
      it { expect(company.total_active_consumed_hours.to_f).to eq 105.6 }
    end

    context 'with no data' do
      let(:company) { Fabricate :company }

      it { expect(company.total_active_consumed_hours).to eq 0 }
    end
  end

  describe '#total_available_hours' do
    context 'with data' do
      include_context 'demands with effort for company'
      it { expect(company.total_available_hours).to eq 100 }
    end

    context 'with no data' do
      let(:company) { Fabricate :company }

      it { expect(company.total_active_consumed_hours).to eq 0 }
    end
  end

  describe '#role_for_user' do
    let(:company) { Fabricate :company }
    let(:other_company) { Fabricate :company }

    let(:user) { Fabricate :user }
    let(:other_user) { Fabricate :user }
    let(:operations_user) { Fabricate :user }
    let(:team_member_operations_user) { Fabricate :user }

    let!(:team_member) { Fabricate :team_member, company: other_company, user: team_member_operations_user }

    let!(:user_company_role) { Fabricate :user_company_role, company: company, user: user, user_role: :manager }
    let!(:other_company_role) { Fabricate :user_company_role, company: company, user: other_user, user_role: :director }
    let!(:operations_company_role) { Fabricate :user_company_role, company: company, user: operations_user, user_role: :operations }
    let!(:team_member_company_role) { Fabricate :user_company_role, company: other_company, user: team_member_operations_user, user_role: :operations }

    it { expect(company.role_for_user(user)).to eq user_company_role }
    it { expect(company.role_for_user(other_user)).to eq other_company_role }
    it { expect(other_company.role_for_user(user)).to be_nil }
    it { expect(company.role_for_user(operations_user)).to be_nil }
    it { expect(other_company.role_for_user(team_member_operations_user)).to eq team_member_company_role }
  end
end
