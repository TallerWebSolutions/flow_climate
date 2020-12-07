# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :customer }
    it { is_expected.to have_many :products }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
    it { is_expected.to have_many(:contracts).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
    it { is_expected.to have_and_belong_to_many :projects }
    it { is_expected.to have_and_belong_to_many(:devise_customers).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :company }
      it { is_expected.to validate_presence_of :name }
    end

    context 'complex ones' do
      let(:company) { Fabricate :company }

      context 'uniqueness' do
        context 'same name in same customer' do
          let!(:customer) { Fabricate :customer, company: company, name: 'zzz' }
          let!(:other_customer) { Fabricate.build :customer, company: company, name: 'zzz' }

          it 'does not accept the model' do
            expect(other_customer.valid?).to be false
            expect(other_customer.errors[:name]).to eq ['Não deve repetir nome de cliente para a mesma empresa.']
          end
        end

        context 'different name in same customer' do
          let!(:customer) { Fabricate :customer, company: company, name: 'zzz' }
          let!(:other_customer) { Fabricate.build :customer, company: company, name: 'aaa' }

          it { expect(other_customer.valid?).to be true }
        end

        context 'same name in different customer' do
          let!(:customer) { Fabricate :customer, company: company, name: 'zzz' }
          let!(:other_customer) { Fabricate.build :customer, name: 'zzz' }

          it { expect(other_customer.valid?).to be true }
        end
      end
    end
  end

  describe '#add_user' do
    let(:devise_customer) { Fabricate :devise_customer }

    context 'when already has the user' do
      let!(:customer) { Fabricate :customer, devise_customers: [devise_customer] }

      before { customer.add_user(devise_customer) }

      it { expect(customer.devise_customers).to eq [devise_customer] }
    end

    context 'when does not have the user' do
      let(:devise_customer) { Fabricate :devise_customer }
      let!(:customer) { Fabricate :customer }

      before { customer.add_user(devise_customer) }

      it { expect(customer.devise_customers).to eq [devise_customer] }
    end
  end

  describe '#exclusive_projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, customers: [customer] }
    let!(:second_project) { Fabricate :project, customers: [customer, other_customer] }
    let!(:third_project) { Fabricate :project, customers: [other_customer] }

    it { expect(customer.exclusive_projects).to eq [first_project] }
    it { expect(other_customer.exclusive_projects).to eq [third_project] }
  end

  describe '#active_exclusive_projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 2.days.ago, end_date: 4.days.from_now }
    let!(:second_project) { Fabricate :project, customers: [customer, other_customer], status: :waiting, start_date: 2.days.from_now, end_date: 4.days.from_now }
    let!(:third_project) { Fabricate :project, customers: [customer], status: :waiting, start_date: 3.days.from_now, end_date: 8.days.from_now }
    let!(:fourth_project) { Fabricate :project, customers: [customer], status: :finished, start_date: 2.days.ago, end_date: 1.day.ago }
    let!(:fifth_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 2.days.ago, end_date: 1.day.ago }
    let!(:sixth_project) { Fabricate :project, customers: [other_customer], status: :executing, start_date: 3.days.ago, end_date: 2.days.from_now }

    it { expect(customer.active_exclusive_projects).to match_array [first_project, third_project] }
  end

  describe '#exclusives_demands' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, customers: [customer], status: :executing }
    let!(:second_project) { Fabricate :project, customers: [customer, other_customer], status: :waiting }
    let!(:third_project) { Fabricate :project, customers: [customer], status: :waiting }
    let!(:fourth_project) { Fabricate :project, customers: [customer], status: :finished }
    let!(:fifth_project) { Fabricate :project, customers: [other_customer], status: :finished }

    let!(:first_demand) { Fabricate :demand, customer: customer }
    let!(:second_demand) { Fabricate :demand, customer: customer }
    let!(:third_demand) { Fabricate :demand, project: first_project }
    let!(:fourth_demand) { Fabricate :demand, project: first_project }
    let!(:fifth_demand) { Fabricate :demand, project: second_project }
    let!(:sixth_demand) { Fabricate :demand, customer: other_customer }
    let!(:seventh_demand) { Fabricate :demand, customer: customer, project: second_project }

    it { expect(customer.exclusives_demands).to match_array [first_demand, second_demand, third_demand, fourth_demand, seventh_demand] }
  end

  describe '#larger_lead_times' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:project) { Fabricate :project, company: company, customers: [customer] }
    let(:other_project) { Fabricate :project, company: company, customers: [customer, other_customer] }

    let!(:first_demand) { Fabricate :demand, customer: customer, project: project, demand_type: :feature, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago }
    let!(:second_demand) { Fabricate :demand, customer: customer, project: project, demand_type: :bug, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, customer: customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, customer: other_customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }

    it { expect(customer.larger_lead_times(0, 3)).to eq [second_demand, first_demand, third_demand] }
    it { expect(customer.larger_lead_times(1, 2)).to eq [third_demand] }
  end

  describe '#current_scope' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    let(:project) { Fabricate :project, company: company, customers: [customer] }
    let(:other_project) { Fabricate :project, company: company, customers: [customer, other_customer] }

    let!(:first_demand) { Fabricate :demand, customer: customer, project: project, demand_type: :feature, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago }
    let!(:second_demand) { Fabricate :demand, customer: customer, project: project, demand_type: :bug, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, customer: customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, customer: other_customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }
    let!(:fifth_demand) { Fabricate :demand, customer: customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }

    it { expect(customer.current_scope).to eq 4 }
  end

  describe '#total_flow_pressure' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }
    let(:no_projects_customer) { Fabricate :customer, company: company }

    let!(:project) { Fabricate :project, company: company, customers: [customer], initial_scope: 10, end_date: 4.weeks.from_now }
    let!(:other_project) { Fabricate :project, company: company, customers: [customer], initial_scope: 8, end_date: 2.weeks.from_now }
    let!(:out_project) { Fabricate :project, company: company, customers: [customer, other_customer], initial_scope: 210, end_date: 30.weeks.from_now }

    it { expect(customer.total_flow_pressure).to be_within(0.1).of(0.8) }
    it { expect(other_customer.total_flow_pressure).to eq 0 }
    it { expect(no_projects_customer.total_flow_pressure).to eq 0 }
  end
end
