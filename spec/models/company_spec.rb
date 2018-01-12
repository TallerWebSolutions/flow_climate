# frozen_string_literal: true

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :users }
    it { is_expected.to have_many :financial_informations }
    it { is_expected.to have_many :customers }
    it { is_expected.to have_many :team_members }
    it { is_expected.to have_many :operation_weekly_results }
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

  context '#members_billable_count' do
    let(:company) { Fabricate :company }
    let!(:members) { Fabricate.times(4, :team_member, company: company, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, company: company, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, company: company, billable: false, billable_type: nil) }

    it { expect(company.members_billable_count).to eq 6 }
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
end
