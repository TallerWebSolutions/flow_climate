# frozen_string_literal: true

RSpec.describe Contract, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:renewal_period).with_values(monthly: 0, yearly: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :contract }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :customer }
    it { is_expected.to validate_presence_of :product }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :total_hours }
    it { is_expected.to validate_presence_of :renewal_period }
    it { is_expected.to validate_presence_of :hours_per_demand }
  end

  context 'scope' do
    describe '.active' do
      it 'returns the active contracts' do
        active_contract = Fabricate :contract, start_date: 2.days.ago, end_date: 2.days.from_now
        other_active_contract = Fabricate :contract, start_date: 7.days.ago, end_date: 9.days.from_now
        Fabricate :contract, start_date: 7.days.from_now, end_date: 9.days.from_now
        Fabricate :contract, start_date: 9.days.ago, end_date: 7.days.ago

        expect(described_class.active).to match_array [active_contract, other_active_contract]
      end
    end
  end

  describe '#hour_value' do
    let(:company) { Fabricate :company }

    it 'returns the current hour value for the contract' do
      customer = Fabricate :customer, company: company
      contract = Fabricate :contract, customer: customer, total_value: 1000, total_hours: 10

      expect(contract.hour_value).to eq 100
    end
  end

  describe '#current_hours_per_demand' do
    let(:company) { Fabricate :company }

    it 'returns the current hours per demand for the contract' do
      customer = Fabricate :customer, company: company
      other_customer = Fabricate :customer, company: company

      project = Fabricate :project, company: company, customers: [customer]
      other_project = Fabricate :project, company: company, customers: [customer]

      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      other_contract = Fabricate :contract, customer: other_customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      no_data_contract = Fabricate :contract, start_date: 2.months.ago, end_date: 3.weeks.from_now

      Fabricate :demand, customer: customer, project: project, demand_type: :feature, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
      Fabricate :demand, customer: customer, project: project, demand_type: :bug, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, customer: customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, customer: other_customer, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

      expect(contract.current_hours_per_demand).to be_within(0.01).of(50.66)
      expect(other_contract.current_hours_per_demand).to eq 53
      expect(no_data_contract.current_hours_per_demand).to eq 0
    end
  end
end
