# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :products }
    it { is_expected.to have_many :projects }
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
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 100, monthly_payment: 1200 }
    let!(:project) { Fabricate :project, team: team, customer: customer, start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 3000, value: 400_000, hour_value: 200, percentage_effort_to_bugs: 100 }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: project, stage: third_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, project: project, created_date: 1.week.ago, end_date: 2.days.ago }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }

    let!(:third_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.today }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.today }

    let!(:fifth_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 5.weeks.ago }
  end

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :maintenance }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    it { expect(customer.active_projects).to match_array [active_project, other_active_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

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
    it { expect(customer.avg_hours_per_demand).to eq 77.0 }
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
    it { expect(customer.percentage_remaining_scope).to eq((customer.remaining_backlog.to_f / customer.last_week_scope.to_f) * 100) }
  end

  describe '#total_flow_pressure' do
    include_context 'demands with effort for customer'
    it { expect(customer.total_flow_pressure).to eq customer.projects.sum(&:flow_pressure) }
  end

  describe '#delivered_scope' do
    include_context 'demands with effort for customer'
    it { expect(customer.delivered_scope).to eq customer.projects.sum(&:total_throughput) }
  end

  describe '#regressive_avg_hours_per_demand' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, initial_scope: 100, customer: customer, start_date: 1.week.ago, end_date: 1.week.from_now }
    let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, start_date: 1.week.ago, end_date: 1.week.from_now }

    context 'having data' do
      it { expect(customer.regressive_avg_hours_per_demand).to eq customer.avg_hours_per_demand }
    end

    context 'having no data' do
      context 'but having results to the company' do
        let(:other_customer) { Fabricate :customer, company: company }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: other_customer, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: other_customer, start_date: 1.week.ago, end_date: 1.week.from_now }

        it { expect(customer.regressive_avg_hours_per_demand).to eq company.avg_hours_per_demand }
      end
    end
  end
end
