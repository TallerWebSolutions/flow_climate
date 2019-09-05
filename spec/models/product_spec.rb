# frozen_string_literal: true

RSpec.describe Product, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to have_many(:teams).through(:projects) }
    it { is_expected.to have_and_belong_to_many(:projects).dependent(:destroy) }
    it { is_expected.to have_many(:portfolio_units).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
    it { is_expected.to have_many(:flow_impacts).through(:projects) }
    it { is_expected.to have_many(:risk_reviews).dependent(:destroy) }
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
    it { is_expected.to delegate_method(:company).to(:customer) }
  end

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing }
    let!(:other_active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :maintenance }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    it { expect(product.active_projects).to match_array [active_project, other_active_project] }
  end

  RSpec.shared_context 'context with no demands' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :cancelled }
  end

  RSpec.shared_context 'consolidations variables data for product', shared_context: :metadata do
    let(:product) { Fabricate :product, name: 'zzz' }
    let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'ccc' }

    let(:other_product) { Fabricate :product, name: 'zzz' }

    let!(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [product.customer], products: [product], value: 15_000, qty_hours: 5000, hour_value: 2.5 }
    let!(:nil_value_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [product.customer], products: [product], status: :executing, value: nil }
    let!(:other_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [product.customer], products: [product], value: 5000, qty_hours: 10_000, hour_value: 2 }
    let!(:other_product_project) { Fabricate :project, customers: [other_product.customer], products: [other_product], start_date: 4.weeks.ago, end_date: 3.weeks.from_now, value: 22_000, qty_hours: 50_000, hour_value: 0.44 }

    let!(:first_demand) { Fabricate :demand, product: product, project: project, created_date: Time.zone.local(2018, 11, 14, 10, 0, 0), end_date: nil, effort_downstream: 900, effort_upstream: 50 }
    let!(:second_demand) { Fabricate :demand, product: product, project: project, created_date: Time.zone.local(2018, 11, 14, 10, 0, 0), end_date: Time.zone.now, effort_downstream: 900, effort_upstream: 50 }
    let!(:third_demand) { Fabricate :demand, product: product, portfolio_unit: portfolio_unit, project: project, created_date: Time.zone.local(2018, 11, 14, 10, 0, 0), end_date: Time.zone.now, effort_downstream: 900, effort_upstream: 50 }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, customers: [customer], products: [product], status: :cancelled }

    it { expect(product.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  describe '#waiting_projects' do
    include_context 'context with no demands'

    it { expect(product.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  describe '#last_week_scope' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }

    after { travel_back }

    include_context 'consolidations variables data for product'
    it { expect(product.last_week_scope).to eq 90 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations variables data for product'
    it { expect(product.avg_hours_per_demand).to eq 950.0 }
  end

  describe '#total_value' do
    include_context 'consolidations variables data for product'
    it { expect(product.total_value).to eq product.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'consolidations variables data for product'
    it { expect(product.remaining_money(3.weeks.from_now).to_f).to eq 15_250.0 }
  end

  describe '#percentage_remaining_money' do
    include_context 'consolidations variables data for product'
    it { expect(product.percentage_remaining_money(3.weeks.from_now).to_f).to eq 76.25 }
  end

  describe '#remaining_backlog' do
    include_context 'consolidations variables data for product'
    it { expect(product.remaining_backlog).to eq product.projects.sum(&:remaining_backlog) }
  end

  describe '#percentage_remaining_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.percentage_remaining_scope).to eq((product.remaining_backlog.to_f / product.last_week_scope) * 100) }
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations variables data for product'
    it { expect(product.total_flow_pressure).to be_within(0.9).of(product.projects.sum(&:flow_pressure)) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.delivered_scope).to eq product.projects.sum(&:total_throughput) }
  end

  describe '#percentage_complete' do
    context 'with no demands' do
      include_context 'context with no demands'
      it { expect(product.percentage_complete).to eq 0 }
    end

    context 'with demands' do
      include_context 'consolidations variables data for product'
      it { expect(product.percentage_complete).to eq 0.6666666666666666 }
    end
  end

  describe '#total_portfolio_demands' do
    context 'with no demands' do
      include_context 'context with no demands'
      it { expect(product.total_portfolio_demands).to eq [] }
    end

    context 'with demands' do
      include_context 'consolidations variables data for product'
      it { expect(product.total_portfolio_demands).to match_array [first_demand, second_demand, third_demand] }
    end
  end

  describe '#total_cost' do
    context 'with no demands' do
      include_context 'context with no demands'
      it { expect(product.total_cost).to eq 0 }
    end

    context 'with demands' do
      include_context 'consolidations variables data for product'
      it { expect(product.total_cost).to eq 0.7125e4 }
    end
  end

  describe '#total_hours' do
    context 'with no demands' do
      include_context 'context with no demands'
      it { expect(product.total_hours).to eq 0 }
    end

    context 'with demands' do
      include_context 'consolidations variables data for product'
      it { expect(product.total_hours).to eq 0.285e4 }
    end
  end
end
