# frozen_string_literal: true

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :users }
    it { is_expected.to have_many :financial_informations }
    it { is_expected.to have_many :customers }
    it { is_expected.to have_many(:products).through(:customers) }
    it { is_expected.to have_many :teams }
    it { is_expected.to have_many :operation_results }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :abbreviation }
  end

  context '#outsourcing_cost_per_week' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:other_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }

    it { expect(company.outsourcing_cost_per_week).to eq((members.sum(&:monthly_payment) + other_members.sum(&:monthly_payment)) / 4) }
  end

  context '#management_cost_per_week' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: other_team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:other_not_billable_members) { Fabricate.times(10, :team_member, team: other_team, billable: false, billable_type: nil) }

    it { expect(company.management_cost_per_week).to eq((not_billable_members.sum(&:monthly_payment) + other_not_billable_members.sum(&:monthly_payment)) / 4) }
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

    let!(:active_project) { Fabricate :project, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, product: product, status: :executing }
    let!(:other_customer_active_project) { Fabricate :project, product: other_product, status: :executing }

    let!(:waiting_project) { Fabricate :project, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, product: product, status: :cancelled }

    it { expect(company.active_projects_count).to eq 3 }
  end

  context '#waiting_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:waiting_project) { Fabricate :project, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, product: product, status: :waiting }
    let!(:other_customer_waiting_project) { Fabricate :project, product: other_product, status: :waiting }

    let!(:executing_project) { Fabricate :project, product: product, status: :executing }
    let!(:finished_project) { Fabricate :project, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, product: product, status: :cancelled }

    it { expect(company.waiting_projects_count).to eq 3 }
  end

  context '#red_projects_count' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let(:first_project) { Fabricate :project, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
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

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customer: other_customer, product: other_product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }

    it { expect(company.projects_count).to eq 2 }
  end

  context '#last_cost_per_hour' do
    context 'having finances' do
      let(:company) { Fabricate :company }
      let(:finance) { Fabricate :financial_information, company: company, finances_date: 1.month.ago }
      let(:other_finance) { Fabricate :financial_information, company: company, finances_date: 2.months.from_now }

      let(:customer) { Fabricate :customer, company: company }

      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

      let(:first_project) { Fabricate :project, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
      let!(:second_project) { Fabricate :project, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
      let!(:third_project) { Fabricate :project, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }

      let!(:first_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 400, result_date: finance.finances_date }
      let!(:second_result) { Fabricate :project_result, project: first_project, qty_hours_downstream: 300, result_date: finance.finances_date }
      let!(:third_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 400, result_date: other_finance.finances_date }
      let!(:fourth_result) { Fabricate :project_result, project: second_project, qty_hours_downstream: 300, result_date: other_finance.finances_date }

      it { expect(company.last_cost_per_hour).to eq other_finance.cost_per_hour }
    end

    context 'having no finances' do
      let(:company) { Fabricate :company }
      it { expect(company.last_cost_per_hour).to eq nil }
    end
  end

  describe '#current_backlog' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, product: product }
    let(:other_project) { Fabricate :project, product: product }
    let(:other_customer_project) { Fabricate :project, product: other_product }
    let(:other_company_project) { Fabricate :project, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.day.ago, known_scope: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: 1.day.ago, known_scope: 100 }

    it { expect(company.current_backlog).to eq 75 }
  end

  context '#current_outsourcing_monthly_available_hours' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }

    it { expect(company.current_outsourcing_monthly_available_hours).to eq(members.sum(&:hours_per_month)) }
  end

  context '#consumed_hours_in_week' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, product: product }
    let(:other_project) { Fabricate :project, product: product }
    let(:other_customer_project) { Fabricate :project, product: other_product }
    let(:other_company_project) { Fabricate :project, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_downstream: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_downstream: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_hours_downstream: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_hours_downstream: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_hours_downstream: 100 }

    it { expect(company.consumed_hours_in_week(1.month.ago.to_date.cweek, 1.month.ago.to_date.cwyear)).to eq 30 }
  end

  context '#th_in_week' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, product: product }
    let(:other_project) { Fabricate :project, product: product }
    let(:other_customer_project) { Fabricate :project, product: other_product }
    let(:other_company_project) { Fabricate :project, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, throughput: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, throughput: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, throughput: 100 }

    it { expect(company.th_in_week(1.month.ago.to_date.cweek, 1.month.ago.to_date.cwyear)).to eq 30 }
  end

  context '#bugs_opened_in_week' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, product: product }
    let(:other_project) { Fabricate :project, product: product }
    let(:other_customer_project) { Fabricate :project, product: other_product }
    let(:other_company_project) { Fabricate :project, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_opened: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_opened: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_bugs_opened: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_bugs_opened: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_bugs_opened: 100 }

    it { expect(company.bugs_opened_in_week(1.month.ago.to_date.cweek, 1.month.ago.to_date.cwyear)).to eq 30 }
  end

  context '#bugs_closed_in_week' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:other_company_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }
    let(:other_company_product) { Fabricate :product, customer: other_company_customer, name: 'zzz' }

    let(:project) { Fabricate :project, product: product }
    let(:other_project) { Fabricate :project, product: product }
    let(:other_customer_project) { Fabricate :project, product: other_product }
    let(:other_company_project) { Fabricate :project, product: other_company_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_closed: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_bugs_closed: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_bugs_closed: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: Time.zone.today, qty_bugs_closed: 50 }
    let!(:fifth_result) { Fabricate :project_result, project: other_company_project, result_date: Time.zone.today, qty_bugs_closed: 100 }

    it { expect(company.bugs_closed_in_week(1.month.ago.to_date.cweek, 1.month.ago.to_date.cwyear)).to eq 30 }
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
end
