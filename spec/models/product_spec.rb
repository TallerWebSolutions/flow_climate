# frozen_string_literal: true

RSpec.describe Product, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :customer }
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

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, customer: customer, product: product, status: :maintenance }
    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(product.active_projects).to match_array [active_project, other_active_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(product.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end
  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, product: product, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, product: product, status: :cancelled }

    it { expect(product.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  RSpec.shared_context 'consolidations variables data for product', shared_context: :metadata do
    let(:product) { Fabricate :product, name: 'zzz' }
    let(:other_product) { Fabricate :product, name: 'zzz' }

    let(:project) { Fabricate :project, customer: product.customer, product: product }
    let(:other_project) { Fabricate :project, customer: product.customer, product: product }
    let(:other_product_project) { Fabricate :project, customer: other_product.customer, product: other_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.week.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_product_project, result_date: 1.week.ago, known_scope: 50 }
  end

  describe '#last_week_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.last_week_scope).to eq 15 }
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
    it { expect(product.percentage_remaining_money).to eq((product.remaining_money / product.total_value) * 100) }
  end

  describe '#total_gap' do
    include_context 'consolidations variables data for product'
    it { expect(product.total_gap).to eq product.projects.sum(&:total_gap) }
  end

  describe '#percentage_remaining_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.percentage_remaining_scope).to eq((product.total_gap.to_f / product.last_week_scope.to_f) * 100) }
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
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(product.regressive_avg_hours_per_demand).to eq product.avg_hours_per_demand }
    end

    context 'having no results' do
      context 'but having results to the customer' do
        let(:other_product) { Fabricate :product, customer: customer }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, known_scope: 20 }

        it { expect(product.regressive_avg_hours_per_demand).to eq customer.avg_hours_per_demand }
      end
      context 'but having results to the company' do
        let(:other_customer) { Fabricate :customer, company: company }
        let(:other_product) { Fabricate :product, customer: other_customer }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: other_customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: other_customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, known_scope: 20 }

        it { expect(product.regressive_avg_hours_per_demand).to eq company.avg_hours_per_demand }
      end
    end
  end
end
