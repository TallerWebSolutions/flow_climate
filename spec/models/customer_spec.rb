# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :products }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
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

    let!(:first_project) { Fabricate :project, customers: [customer], status: :executing }
    let!(:second_project) { Fabricate :project, customers: [customer, other_customer], status: :waiting }
    let!(:third_project) { Fabricate :project, customers: [customer], status: :waiting }
    let!(:fourth_project) { Fabricate :project, customers: [customer], status: :finished }
    let!(:fifth_project) { Fabricate :project, customers: [other_customer], status: :finished }

    it { expect(customer.active_exclusive_projects).to match_array [first_project, third_project] }
  end

  describe '#exclusives_demands_to_customer' do
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

    it { expect(customer.exclusives_demands_to_customer).to match_array [first_demand, second_demand, third_demand, fourth_demand, seventh_demand] }
  end
end
