# frozen_string_literal: true

RSpec.describe Product, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :team }
    it { is_expected.to have_many(:projects).dependent(:restrict_with_error) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :customer }
      it { is_expected.to validate_presence_of :name }
    end
    context 'complex ones' do
      let(:customer) { Fabricate :customer }

      context 'uniqueness' do
        context 'same name in same customer' do
          let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:other_product) { Fabricate.build :product, customer: customer, name: 'zzz' }
          it 'does not accept the model' do
            expect(other_product.valid?).to be false
            expect(other_product.errors[:name]).to eq ['Não deve repetir nome de produto para o mesmo cliente.']
          end
        end
        context 'different name in same customer' do
          let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:other_product) { Fabricate.build :product, customer: customer, name: 'aaa' }
          it { expect(other_product.valid?).to be true }
        end
        context 'different name in same customer' do
          let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:other_product) { Fabricate.build :product, name: 'zzz' }
          it { expect(other_product.valid?).to be true }
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
  end

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :maintenance }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    it { expect(product.active_projects).to match_array [active_project, other_active_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customer: customer, product: product, status: :cancelled }

    it { expect(product.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end
  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: customer, product: product, status: :cancelled }

    it { expect(product.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  RSpec.shared_context 'consolidations variables data for product', shared_context: :metadata do
    let(:product) { Fabricate :product, name: 'zzz' }
    let(:other_product) { Fabricate :product, name: 'zzz' }

    let!(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: product.customer, product: product, value: 2000, qty_hours: 5000, hour_value: 2.5 }
    let!(:other_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customer: product.customer, product: product, value: 5000, qty_hours: 10_000, hour_value: 2 }
    let!(:other_product_project) { Fabricate :project, customer: other_product.customer, product: other_product, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, value: 22_000, qty_hours: 50_000, hour_value: 0.44 }

    let!(:demand) { Fabricate :demand, project: project, effort_downstream: 900, effort_upstream: 50 }
  end

  describe '#last_week_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.last_week_scope).to eq 61 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations variables data for product'
    it { expect(product.avg_hours_per_demand).to eq product.projects.sum(&:avg_hours_per_demand) / product.projects_count.to_f }
  end

  describe '#total_value' do
    include_context 'consolidations variables data for product'
    it { expect(product.total_value).to eq product.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'consolidations variables data for product'
    it { expect(product.remaining_money).to eq product.projects.sum(&:remaining_money) }
  end

  describe '#percentage_remaining_money' do
    include_context 'consolidations variables data for product'
    it { expect(product.percentage_remaining_money.to_f).to eq 66.07142857142857 }
  end

  describe '#backlog_remaining' do
    include_context 'consolidations variables data for product'
    it { expect(product.backlog_remaining).to eq product.projects.sum(&:backlog_remaining) }
  end

  describe '#percentage_remaining_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.percentage_remaining_scope).to eq((product.backlog_remaining.to_f / product.last_week_scope.to_f) * 100) }
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations variables data for product'
    it { expect(product.total_flow_pressure).to eq product.projects.sum(&:flow_pressure) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.delivered_scope).to eq product.projects.sum(&:total_throughput) }
  end

  describe '#regressive_avg_hours_per_demand' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let!(:first_project) { Fabricate :project, initial_scope: 100, customer: customer, product: product, start_date: 1.week.ago, end_date: 1.week.from_now }
    let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, product: product, start_date: 1.week.ago, end_date: 1.week.from_now }

    context 'having results' do
      it { expect(product.regressive_avg_hours_per_demand).to eq product.avg_hours_per_demand }
    end

    context 'having no results' do
      context 'but having results to the customer' do
        let(:other_product) { Fabricate :product, customer: customer }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }

        it { expect(product.regressive_avg_hours_per_demand).to eq customer.avg_hours_per_demand }
      end
      context 'but having results to the company' do
        let(:other_customer) { Fabricate :customer, company: company }
        let(:other_product) { Fabricate :product, customer: other_customer }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: other_customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: other_customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }

        it { expect(product.regressive_avg_hours_per_demand).to eq company.avg_hours_per_demand }
      end
    end
  end
end
