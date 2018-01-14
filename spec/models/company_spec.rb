# frozen_string_literal: true

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :users }
    it { is_expected.to have_many :financial_informations }
    it { is_expected.to have_many :customers }
    it { is_expected.to have_many :team_members }
    it { is_expected.to have_many :operation_results }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  context '#outsourcing_cost_per_week' do
    let(:company) { Fabricate :company }
    let!(:members) { Fabricate.times(4, :team_member, company: company, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, company: company, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, company: company, billable: false, billable_type: nil) }

    it { expect(company.outsourcing_cost_per_week).to eq(members.sum(&:monthly_payment) / 4) }
  end

  context '#management_cost_per_week' do
    let(:company) { Fabricate :company }
    let!(:members) { Fabricate.times(4, :team_member, company: company, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, company: company, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, company: company, billable: false, billable_type: nil) }

    it { expect(company.management_cost_per_week).to eq(not_billable_members.sum(&:monthly_payment) / 4) }
  end

  context '#outsourcing_members_billable_count' do
    let(:company) { Fabricate :company }
    let!(:members) { Fabricate.times(4, :team_member, company: company, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, company: company, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, company: company, billable: false, billable_type: nil) }

    it { expect(company.outsourcing_members_billable_count).to eq 6 }
  end

  context '#management_count' do
    let(:company) { Fabricate :company }
    let!(:members) { Fabricate.times(4, :team_member, company: company, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, company: company, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, company: company, billable: false, billable_type: nil) }

    it { expect(company.management_count).to eq 10 }
  end

  context '#active_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let!(:active_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:other_active_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:other_customer_active_project) { Fabricate :project, customer: other_customer, status: :executing }

    let!(:waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, status: :cancelled }

    it { expect(company.active_projects_count).to eq 3 }
  end

  context '#waiting_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let!(:waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:other_customer_waiting_project) { Fabricate :project, customer: other_customer, status: :waiting }

    let!(:executing_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:finished_project) { Fabricate :project, customer: customer, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, status: :cancelled }

    it { expect(company.waiting_projects_count).to eq 3 }
  end

  context '#red_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 400 }
    let!(:second_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 300 }
    let!(:third_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 400 }
    let!(:fourth_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 300 }

    it { expect(company.red_projects_count).to eq 2 }
  end

  context '#projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer }

    let!(:first_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customer: other_customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }

    it { expect(company.projects_count).to eq 2 }
  end

  context '#last_cost_per_hour' do
    let(:company) { Fabricate :company }
    let(:finance) { Fabricate :financial_information, company: company, finances_date: 1.month.ago }
    let(:other_finance) { Fabricate :financial_information, company: company, finances_date: 2.months.from_now }

    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 400, result_date: finance.finances_date }
    let!(:second_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 300, result_date: finance.finances_date }
    let!(:third_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 400, result_date: other_finance.finances_date }
    let!(:fourth_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 300, result_date: other_finance.finances_date }

    it { expect(company.last_cost_per_hour).to eq other_finance.cost_per_hour }
  end

  describe '#current_backlog' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:project) { Fabricate :project, customer: customer }
    let(:other_project) { Fabricate :project, customer: customer }
    let(:other_customer_project) { Fabricate :project, customer: other_customer }
    let(:other_company_project) { Fabricate :project, customer: other_company_customer }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.day.ago, known_scope: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: 1.day.ago, known_scope: 100 }

    it { expect(company.current_backlog).to eq 75 }
  end

  context '#current_monthly_available_hours' do
    let(:company) { Fabricate :company }
    let!(:members) { Fabricate.times(4, :team_member, company: company, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, company: company, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, company: company, billable: false, billable_type: nil) }

    it { expect(company.current_monthly_available_hours).to eq(members.sum(&:hours_per_month)) }
  end
end
