# frozen_string_literal: true

RSpec.describe Contract do
  context 'enums' do
    it { is_expected.to define_enum_for(:renewal_period).with_values(monthly: 0, yearly: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to(:contract).optional }

    it { is_expected.to have_many :contract_consolidations }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
    it { is_expected.to have_many :contract_estimation_change_histories }
  end

  context 'validations' do
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

        expect(described_class.active(Time.zone.today)).to match_array [active_contract, other_active_contract]
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
    it { is_expected.to delegate_method(:company).to(:customer) }
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

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    it 'returns the current hours per demand for the contract' do
      customer = Fabricate :customer, company: company
      other_customer = Fabricate :customer, company: company

      project = Fabricate :project, company: company, customers: [customer]
      other_project = Fabricate :project, company: company, customers: [customer]

      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      other_contract = Fabricate :contract, customer: other_customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      no_data_contract = Fabricate :contract, start_date: 2.months.ago, end_date: 3.weeks.from_now

      Fabricate :demand, customer: customer, contract: contract, project: project, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
      Fabricate :demand, customer: customer, contract: contract, project: project, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, customer: customer, contract: contract, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, customer: other_customer, contract: other_contract, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

      expect(contract.current_hours_per_demand).to be_within(0.01).of(50.66)
      expect(other_contract.current_hours_per_demand).to eq 53
      expect(no_data_contract.current_hours_per_demand).to eq 0
    end
  end

  describe '#current_estimate_gap' do
    let(:company) { Fabricate :company }

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    it 'returns the current gaps to the hours estimated' do
      customer = Fabricate :customer, company: company
      other_customer = Fabricate :customer, company: company

      project = Fabricate :project, company: company, customers: [customer]
      other_project = Fabricate :project, company: company, customers: [customer]

      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      other_contract = Fabricate :contract, customer: other_customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      no_data_contract = Fabricate :contract, start_date: 2.months.ago, end_date: 3.weeks.from_now

      Fabricate :demand, customer: customer, contract: contract, project: project, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
      Fabricate :demand, customer: customer, contract: contract, project: project, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, customer: customer, contract: contract, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, customer: other_customer, contract: other_contract, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

      expect(contract.current_estimate_gap.to_f).to eq 0.6888888888888889
      expect(other_contract.current_estimate_gap.to_f).to eq 0.7666666666666667
      expect(no_data_contract.current_estimate_gap.to_f).to eq(-1)
    end
  end

  describe '#remaining_work' do
    let(:company) { Fabricate :company }
    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    it 'returns the remaining backlog for the estimation in the contract' do
      customer = Fabricate :customer, company: company
      other_customer = Fabricate :customer, company: company

      project = Fabricate :project, company: company, customers: [customer]
      other_project = Fabricate :project, company: company, customers: [customer]

      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, total_hours: 200
      other_contract = Fabricate :contract, customer: other_customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, total_hours: 100
      no_data_contract = Fabricate :contract, start_date: 2.months.ago, end_date: 3.weeks.from_now, total_hours: 150

      Fabricate :demand, customer: customer, contract: contract, project: project, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
      Fabricate :demand, customer: customer, contract: contract, project: project, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, customer: customer, contract: contract, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, customer: other_customer, contract: other_contract, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

      expect(contract.remaining_work).to eq 0.9473684210526314
      expect(contract.remaining_work(3.weeks.ago)).to eq 3.9473684210526314
      expect(other_contract.remaining_work).to eq 0.8867924528301887
      expect(no_data_contract.remaining_work).to eq 5
    end
  end

  describe '#remaining_weeks' do
    let(:company) { Fabricate :company }

    it 'returns the remaining weeks for the estimation in the contract' do
      customer = Fabricate :customer, company: company

      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, total_hours: 200

      expect(contract.remaining_weeks).to eq 4
      expect(contract.remaining_weeks(2.weeks.ago.to_date)).to eq 6
    end
  end

  describe '#hours_per_demand_to_date' do
    let(:company) { Fabricate :company }

    it 'returns the hours_per_demand in date' do
      customer = Fabricate :customer, company: company
      now = Time.zone.now

      travel_to 1.day.ago do
        allow(Time.zone).to receive(:now).and_return(1.day.ago)
        contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, hours_per_demand: 10

        expect(contract.hours_per_demand_to_date).to eq 10
        expect(contract.hours_per_demand_to_date(2.weeks.ago.to_date)).to eq 10
      end

      contract = described_class.last
      allow(Time.zone).to receive(:now).and_return(now)
      contract.update(hours_per_demand: 30)
      expect(contract.hours_per_demand_to_date).to eq 30
      expect(contract.hours_per_demand_to_date(1.day.ago)).to eq 10
    end
  end

  describe '#flow_pressure' do
    let(:company) { Fabricate :company }

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    it 'returns the flow_pressure in date' do
      customer = Fabricate :customer, company: company
      other_customer = Fabricate :customer, company: company

      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, hours_per_demand: 10
      other_contract = Fabricate :contract, customer: customer, start_date: 1.month.ago, end_date: 5.weeks.from_now, hours_per_demand: 10
      empty_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
      past_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.ago

      Fabricate :demand, customer: customer, contract: contract, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
      Fabricate.times(40, :demand, customer: customer, contract: contract, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10)
      Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: nil, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: nil, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, customer: other_customer, contract: other_contract, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

      expect(contract.flow_pressure).to eq 1.8181818181818181
      expect(empty_contract.flow_pressure).to eq 0
      expect(past_contract.flow_pressure).to eq 0
    end
  end

  describe '#avg_hours_per_month' do
    let(:company) { Fabricate :company }

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }

    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer, company: company }

    context 'with contract in the present' do
      it 'returns the flow_pressure in date' do
        contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, hours_per_demand: 10
        other_contract = Fabricate :contract, customer: customer, start_date: 1.month.ago, end_date: 5.weeks.from_now, hours_per_demand: 10
        empty_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now
        past_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.ago

        Fabricate :demand, customer: customer, contract: contract, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
        Fabricate.times(40, :demand, customer: customer, contract: contract, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10)
        Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
        Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: nil, effort_downstream: 2, effort_upstream: 18
        Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
        Fabricate :demand, customer: customer, contract: contract, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: nil, effort_downstream: 43, effort_upstream: 49
        Fabricate :demand, customer: other_customer, contract: other_contract, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

        expect(contract.avg_hours_per_month).to be_within(0.1).of 50.6
        expect(empty_contract.avg_hours_per_month).to eq 0
        expect(past_contract.avg_hours_per_month).to eq 0
      end

      context 'with contract in the present' do
        it 'returns the flow_pressure in date' do
          contract = Fabricate :contract, customer: customer, start_date: 2.months.from_now, end_date: 3.months.from_now, hours_per_demand: 10

          expect(contract.avg_hours_per_month).to eq 0
        end
      end
    end
  end

  describe '#consumed_hours' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    it 'sums the consumed total' do
      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, hours_per_demand: 10
      empty_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now

      Fabricate :contract_consolidation, contract: contract, consumed_hours: 150, consolidation_date: Time.zone.today
      Fabricate :contract_consolidation, contract: contract, consumed_hours: 100, consolidation_date: 1.day.ago

      expect(contract.consumed_hours).to eq 150
      expect(empty_contract.consumed_hours).to eq 0
    end
  end

  describe '#remaining_hours' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    it 'sums the consumed total' do
      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, hours_per_demand: 10
      empty_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now

      Fabricate :contract_consolidation, contract: contract, consumed_hours: 150, consolidation_date: Time.zone.today
      Fabricate :contract_consolidation, contract: contract, consumed_hours: 100, consolidation_date: 1.day.ago

      expect(contract.remaining_hours).to eq(-115)
      expect(empty_contract.remaining_hours).to eq 35
    end
  end

  describe '#consumed_percentage' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    it 'sums the consumed total' do
      contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now, hours_per_demand: 10, total_hours: 400
      empty_contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 3.weeks.from_now

      Fabricate :contract_consolidation, contract: contract, consumed_hours: 150, consolidation_date: Time.zone.today
      Fabricate :contract_consolidation, contract: contract, consumed_hours: 100, consolidation_date: 1.day.ago

      expect(contract.consumed_percentage).to eq 0.375
      expect(empty_contract.consumed_percentage).to eq 0
    end
  end
end
