# frozen_string_literal: true

RSpec.describe FinancialInformation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :finances_date }
    it { is_expected.to validate_presence_of :income_total }
    it { is_expected.to validate_presence_of :expenses_total }
  end

  context 'scopes' do
    before { travel_to Date.new(2018, 8, 31) }

    after { travel_back }

    pending '.for_month'
  end

  describe '#financial_result' do
    let(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }

    it { expect(finances.financial_result).to eq 8.2 }
  end

  describe '#throughput_in_month' do
    before { travel_to Date.new(2018, 10, 25) }

    after { travel_back }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, company: company, customers: [customer], start_date: 2.months.ago, end_date: 3.months.from_now }

    let(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, queue: false, end_point: true }

    let!(:first_demand) { Fabricate :demand, project: project }
    let!(:second_demand) { Fabricate :demand, project: project }
    let!(:third_demand) { Fabricate :demand, project: project }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: 1.month.ago, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, start_time: 1.month.ago, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, start_time: 7.weeks.ago, finish_time: nil }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago }
    let!(:third_transition) { Fabricate :demand_transition, stage: first_stage, demand: third_demand, last_time_in: 2.months.ago }

    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    it { expect(finances.throughput_in_month.count).to eq 2 }
  end

  RSpec.shared_context 'demands with effort for finances', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, company: company, customers: [customer], start_date: 2.months.ago, end_date: 3.months.from_now }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: project, end_date: 1.month.ago }
    let!(:second_demand) { Fabricate :demand, project: project, end_date: 1.month.ago }
    let!(:third_demand) { Fabricate :demand, project: project, end_date: 2.months.ago }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: 1.month.ago, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, start_time: 1.month.ago, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, start_time: 7.weeks.ago, finish_time: nil }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }
    let!(:third_transition) { Fabricate :demand_transition, stage: first_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 6.weeks.ago }

    let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }
    let!(:sixth_transition) { Fabricate :demand_transition, stage: second_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 6.weeks.ago }
  end

  describe '#income_per_hour' do
    before { travel_to Date.new(2018, 11, 19) }

    after { travel_back }

    include_context 'demands with effort for finances'

    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    it { expect(finances.income_per_hour.to_f).to eq 0.18181818181818182 }
  end

  describe '#cost_per_hour' do
    before { travel_to Date.new(2018, 11, 19) }

    after { travel_back }

    include_context 'demands with effort for finances'

    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    it { expect(finances.cost_per_hour.to_f).to eq 0.10873440285204991 }
  end

  describe '#project_delivered_hours' do
    before { travel_to Date.new(2018, 11, 19) }

    after { travel_back }

    include_context 'demands with effort for finances'

    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    it { expect(finances.project_delivered_hours).to eq 112.2 }
  end

  describe '#hours_per_demand' do
    before { travel_to Date.new(2018, 11, 19) }

    after { travel_back }

    include_context 'demands with effort for finances'

    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    it { expect(finances.hours_per_demand).to eq 56.1 }
  end

  describe '#red?' do
    let(:company) { Fabricate :company }

    context 'when the expenses are greather than incomes' do
      let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 30 }

      it { expect(finances.red?).to be true }
    end

    context 'when the expenses are smaller than incomes' do
      let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 1 }

      it { expect(finances.red?).to be false }
    end
  end

  describe '#to_h' do
    let(:finance) { Fabricate :financial_information }

    it { expect(finance.to_h).to eq('id' => finance.id, 'finances_date' => finance.finances_date, 'income_total' => finance.income_total, 'expenses_total' => finance.expenses_total) }
  end
end
