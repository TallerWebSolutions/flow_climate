# frozen_string_literal: true

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :users }
    it { is_expected.to have_many(:financial_informations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:customers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:products).through(:customers) }
    it { is_expected.to have_many(:projects).through(:customers) }
    it { is_expected.to have_many(:teams).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:operation_results).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:company_settings).dependent(:destroy) }
    it { is_expected.to have_many(:pipefy_configs).dependent(:destroy) }
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

  context '#outsourcing_cost_per_week' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:other_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }

    it { expect(company.outsourcing_cost).to eq((members.sum(&:total_monthly_payment) + other_members.sum(&:total_monthly_payment))) }
  end

  context '#management_cost_per_week' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:other_not_billable_members) { Fabricate.times(10, :team_member, team: other_team, billable: false, billable_type: nil) }

    it { expect(company.management_cost).to eq((not_billable_members.sum(&:total_monthly_payment) + other_not_billable_members.sum(&:total_monthly_payment))) }
  end

  context '#outsourcing_members_billable_count' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:other_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }

    it { expect(company.outsourcing_members_billable_count).to eq 6 }
  end

  context '#management_count' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:other_not_billable_members) { Fabricate.times(3, :team_member, team: other_team, billable: false, billable_type: nil) }

    it { expect(company.management_count).to eq 13 }
  end

  context '#active_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:other_customer_active_project) { Fabricate :project, customer: other_product.customer, product: other_product, status: :executing }

    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(company.active_projects_count).to eq 3 }
  end

  context '#waiting_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:other_customer_waiting_project) { Fabricate :project, customer: other_product.customer, product: other_product, status: :waiting }

    let!(:executing_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

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

  context '#current_cost_per_hour' do
    context 'having finances' do
      let(:company) { Fabricate :company }
      let!(:first_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, expenses_total: 300 }
      let!(:second_finance) { Fabricate :financial_information, company: company, finances_date: 1.week.ago, expenses_total: 200 }
      let!(:third_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.from_now, expenses_total: 100 }

      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }
      let(:other_company_customer) { Fabricate :customer }

      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
      let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

      let(:project) { Fabricate :project, customer: customer, product: product }
      let(:other_project) { Fabricate :project, customer: customer, product: product }
      let(:other_customer_project) { Fabricate :project, customer: other_customer, product: other_product }
      let(:other_company_project) { Fabricate :project, customer: other_company_customer, product: other_company_product }

      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, qty_hours_downstream: 10, qty_hours_upstream: 20 }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, qty_hours_downstream: 20, qty_hours_upstream: 30 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.week.ago, qty_hours_downstream: 5, qty_hours_upstream: 40 }
      let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.week.ago, qty_hours_downstream: 50, qty_hours_upstream: 10 }
      let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: 1.week.ago, qty_hours_downstream: 100, qty_hours_upstream: 50 }

      it { expect(company.current_cost_per_hour.to_f).to eq 1.0810810810810811 }
    end

    context 'having no finances' do
      let(:company) { Fabricate :company }
      it { expect(company.current_cost_per_hour).to eq 0 }
    end
  end

  context '#current_hours_per_demand' do
    context 'having finances' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }
      let(:other_company_customer) { Fabricate :customer }

      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
      let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

      let(:project) { Fabricate :project, customer: customer, product: product }
      let(:other_project) { Fabricate :project, customer: customer, product: product }
      let(:other_customer_project) { Fabricate :project, customer: other_customer, product: other_product }
      let(:other_company_project) { Fabricate :project, customer: other_company_customer, product: other_company_product }

      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_upstream: 0, qty_hours_downstream: 10 }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_upstream: 0, qty_hours_downstream: 20 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_hours_upstream: 0, qty_hours_downstream: 5 }
      let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_hours_upstream: 0, qty_hours_downstream: 100 }

      it { expect(company.current_hours_per_demand).to eq 55 }
    end

    context 'having no finances' do
      let(:company) { Fabricate :company }
      it { expect(company.current_hours_per_demand).to eq 0 }
    end
  end

  describe '#last_week_scope' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_customer, product: other_product }
    let(:other_company_project) { Fabricate :project, customer: other_company_customer, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.week.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.week.ago, known_scope: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: 1.week.ago, known_scope: 100 }

    it { expect(company.last_week_scope).to eq 65 }
  end

  describe '#avg_hours_per_demand' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_customer, product: other_product }
    let(:other_company_project) { Fabricate :project, customer: other_company_customer, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.day.ago, known_scope: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: 1.day.ago, known_scope: 100 }

    it { expect(company.avg_hours_per_demand).to eq company.customers.sum(&:avg_hours_per_demand) / company.customers.count }
  end

  context '#current_outsourcing_monthly_available_hours' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }

    it { expect(company.current_outsourcing_monthly_available_hours).to eq(members.sum(&:hours_per_month)) }
  end

  context '#consumed_hours_in_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_product.customer, product: other_product }
    let(:other_company_project) { Fabricate :project, customer: other_company_product.customer, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_upstream: 0, qty_hours_downstream: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_upstream: 0, qty_hours_downstream: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_hours_upstream: 0, qty_hours_downstream: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_hours_upstream: 0, qty_hours_downstream: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_hours_upstream: 0, qty_hours_downstream: 100 }

    it { expect(company.consumed_hours_in_month(1.month.ago.to_date)).to eq 30 }
  end

  context '#throughput_in_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_product.customer, product: other_product }
    let(:other_company_project) { Fabricate :project, customer: other_company_product.customer, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, throughput: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, throughput: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, throughput: 100 }

    it { expect(company.throughput_in_month(1.month.ago.to_date)).to eq 30 }
  end

  context '#products_count' do
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

    let!(:starting_project) { Fabricate :project, customer: customer, status: :waiting, initial_scope: 5, start_date: Time.zone.today, end_date: 3.days.from_now }
    let!(:first_project) { Fabricate :project, customer: customer, status: :executing, initial_scope: 10, start_date: Time.zone.today, end_date: 4.days.from_now }
    let!(:second_project) { Fabricate :project, customer: other_customer, status: :executing, initial_scope: 40, start_date: 1.day.from_now, end_date: 5.days.from_now }
    let!(:third_project) { Fabricate :project, customer: other_customer, status: :executing, initial_scope: 20, start_date: 2.days.from_now, end_date: 6.days.from_now }
  end

  context '#top_three_flow_pressure' do
    include_context 'projects to company bulletin'
    it { expect(company.top_three_flow_pressure).to eq [second_project, third_project, first_project] }
  end

  context '#next_starting_project' do
    include_context 'projects to company bulletin'
    it { expect(company.next_starting_project).to eq starting_project }
  end

  context '#next_finishing_project' do
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

  describe '#total_available_hours' do
    context 'having teams' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let!(:first_team_member) { Fabricate :team_member, team: team, hours_per_month: 100 }
      let!(:second_team_member) { Fabricate :team_member, team: team, hours_per_month: 160 }
      let!(:third_team_member) { Fabricate :team_member, team: other_team, hours_per_month: 160 }

      it { expect(company.total_available_hours).to eq 420 }
    end
    context 'having no teams' do
      let(:company) { Fabricate :company }
      it { expect(company.total_available_hours).to eq 0 }
    end
  end

  describe '#total_active_hours' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having active projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 20 }
      let!(:second_project) { Fabricate :project, customer: customer, status: :maintenance, qty_hours: 25 }
      let!(:third_project) { Fabricate :project, customer: customer, status: :cancelled, qty_hours: 40 }
      let!(:fourth_project) { Fabricate :project, customer: customer, status: :finished, qty_hours: 35 }
      let!(:fifth_project) { Fabricate :project, customer: customer, status: :waiting, qty_hours: 10 }

      it { expect(company.total_active_hours).to eq 55 }
    end
    context 'having no active projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :cancelled, qty_hours: 40 }
      let!(:second_project) { Fabricate :project, customer: customer, status: :finished, qty_hours: 35 }
      it { expect(company.total_active_hours).to eq 0 }
    end
  end

  describe '#total_active_consumed_hours' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having active projects' do
      let(:first_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 20 }
      let(:second_project) { Fabricate :project, customer: customer, status: :maintenance, qty_hours: 25 }
      let(:third_project) { Fabricate :project, customer: customer, status: :cancelled, qty_hours: 40 }
      let(:fourth_project) { Fabricate :project, customer: customer, status: :finished, qty_hours: 35 }
      let(:fifth_project) { Fabricate :project, customer: customer, status: :waiting, qty_hours: 10 }

      let!(:first_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }
      let!(:third_result) { Fabricate :project_result, project: third_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }
      let!(:third_result) { Fabricate :project_result, project: fourth_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }
      let!(:fifth_result) { Fabricate :project_result, project: fifth_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }

      it { expect(company.total_active_consumed_hours).to eq 90 }
    end

    context 'having no active projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :cancelled, qty_hours: 40 }
      let!(:second_project) { Fabricate :project, customer: customer, status: :finished, qty_hours: 35 }
      let!(:first_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 10, qty_hours_upstream: 20 }

      it { expect(company.total_active_consumed_hours).to eq 0 }
    end
  end

  describe '#bugs_opened_in_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_product.customer, product: other_product }
    let(:other_company_project) { Fabricate :project, customer: other_company_product.customer, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_opened: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_opened: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_bugs_opened: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_bugs_opened: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_bugs_opened: 100 }

    it { expect(company.bugs_opened_in_month(1.month.ago.to_date)).to eq 30 }
  end

  describe '#bugs_closed_in_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_product.customer, product: other_product }
    let(:other_company_project) { Fabricate :project, customer: other_company_product.customer, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_closed: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_closed: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_bugs_closed: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_bugs_closed: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_bugs_closed: 100 }

    it { expect(company.bugs_closed_in_month(1.month.ago.to_date)).to eq 30 }
  end
end
