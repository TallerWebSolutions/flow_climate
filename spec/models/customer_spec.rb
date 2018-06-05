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

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, customer: customer, product: product, status: :maintenance }
    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(customer.active_projects).to match_array [active_project, other_active_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end
  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  RSpec.shared_context 'consolidations variables data for customer', shared_context: :metadata do
    let(:customer) { Fabricate :customer }
    let(:other_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.weeks.ago, end_date: 2.weeks.from_now }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_customer, product: other_product }
    let(:blank_project) { Fabricate :project, customer: customer, product: other_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 10, qty_hours_upstream: 17, qty_hours_downstream: 20, throughput_upstream: 2, throughput_downstream: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago, known_scope: 20, qty_hours_upstream: 12, qty_hours_downstream: 23, throughput_upstream: 1, throughput_downstream: 2 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.week.ago, known_scope: 5, qty_hours_upstream: 9, qty_hours_downstream: 8, throughput_upstream: 1, throughput_downstream: 14 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.week.ago, known_scope: 50 }
  end

  describe '#last_week_scope' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.last_week_scope).to eq 15 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.avg_hours_per_demand).to eq 2.966666666666667 }
  end

  describe '#total_value' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.total_value).to eq customer.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.remaining_money).to eq customer.projects.sum(&:remaining_money) }
  end

  describe '#percentage_remaining_money' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.percentage_remaining_money).to eq((customer.remaining_money / customer.total_value) * 100) }
  end

  describe '#total_gap' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.total_gap).to eq customer.projects.sum(&:total_gap) }
  end

  describe '#percentage_remaining_scope' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.percentage_remaining_scope).to eq((customer.total_gap.to_f / customer.last_week_scope.to_f) * 100) }
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.total_flow_pressure).to eq customer.projects.sum(&:flow_pressure) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.delivered_scope).to eq customer.projects.sum(&:total_throughput) }
  end

  describe '#regressive_avg_hours_per_demand' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, initial_scope: 100, customer: customer, start_date: 1.week.ago, end_date: 1.week.from_now }
    let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, start_date: 1.week.ago, end_date: 1.week.from_now }

    context 'having results' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(customer.regressive_avg_hours_per_demand).to eq customer.avg_hours_per_demand }
    end

    context 'having no results' do
      context 'but having results to the company' do
        let(:other_customer) { Fabricate :customer, company: company }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: other_customer, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: other_customer, start_date: 1.week.ago, end_date: 1.week.from_now }

        let!(:result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, known_scope: 20 }

        it { expect(customer.regressive_avg_hours_per_demand).to eq company.avg_hours_per_demand }
      end
    end
  end
end
