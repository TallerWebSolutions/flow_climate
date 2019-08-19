# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :products }
    it { is_expected.to have_and_belong_to_many :projects }
  end

  context 'validations' do
    context 'complex ones' do
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

        context 'different name in same customer' do
          let!(:customer) { Fabricate :customer, company: company, name: 'zzz' }
          let!(:other_customer) { Fabricate.build :customer, name: 'zzz' }

          it { expect(other_customer.valid?).to be true }
        end
      end
    end
  end

  RSpec.shared_context 'demands with effort for customer', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, monthly_payment: 1200 }
    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 3.months.ago.to_date, end_date: nil }
    let!(:project) { Fabricate :project, team: team, customers: [customer], start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 3000, value: 400_000, hour_value: 200, percentage_effort_to_bugs: 100 }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false, order: 0 }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true, order: 1 }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true, order: 2 }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: project, stage: third_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, project: project, created_date: 1.week.ago, end_date: 2.days.ago }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: 1.month.ago, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, start_time: 1.month.ago, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, start_time: 7.weeks.ago, finish_time: nil }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }

    let!(:third_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.today }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.today }

    let!(:fifth_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 5.weeks.ago }
  end

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing }
    let!(:other_active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :maintenance }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    it { expect(customer.active_projects).to match_array [active_project, other_active_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  describe '#last_week_scope' do
    include_context 'demands with effort for customer'
    it { expect(customer.last_week_scope).to eq 33 }
  end

  describe '#avg_hours_per_demand' do
    before { travel_to Date.new(2018, 11, 19) }

    after { travel_back }

    include_context 'demands with effort for customer'
    it { expect(customer.avg_hours_per_demand).to eq 59.4 }
  end

  describe '#total_value' do
    include_context 'demands with effort for customer'
    it { expect(customer.total_value).to eq customer.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'demands with effort for customer'
    it { expect(customer.remaining_money).to eq customer.projects.sum(&:remaining_money) }
  end

  describe '#percentage_remaining_money' do
    include_context 'demands with effort for customer'
    it { expect(customer.percentage_remaining_money).to eq((customer.remaining_money / customer.total_value) * 100) }
  end

  describe '#remaining_backlog' do
    include_context 'demands with effort for customer'
    it { expect(customer.remaining_backlog).to eq customer.projects.sum(&:remaining_backlog) }
  end

  describe '#percentage_remaining_scope' do
    include_context 'demands with effort for customer'
    it { expect(customer.percentage_remaining_scope).to eq((customer.remaining_backlog.to_f / customer.last_week_scope) * 100) }
  end

  describe '#total_flow_pressure' do
    include_context 'demands with effort for customer'
    it { expect(customer.total_flow_pressure).to be_within(0.9).of(customer.projects.sum(&:flow_pressure)) }
  end

  describe '#delivered_scope' do
    include_context 'demands with effort for customer'
    it { expect(customer.delivered_scope).to eq customer.projects.sum(&:total_throughput) }
  end
end
