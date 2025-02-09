# frozen_string_literal: true

RSpec.describe Product do
  context 'with associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to(:customer).optional }

    it { is_expected.to have_many(:teams).through(:projects) }
    it { is_expected.to have_many(:memberships).through(:teams) }
    it { is_expected.to have_many(:projects).dependent(:destroy) }
    it { is_expected.to have_many(:products_projects).dependent(:destroy) }
    it { is_expected.to have_many(:portfolio_units).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
    it { is_expected.to have_many(:flow_events).through(:projects) }
    it { is_expected.to have_many(:risk_reviews).dependent(:destroy) }
    it { is_expected.to have_many(:service_delivery_reviews).dependent(:destroy) }
    it { is_expected.to have_many(:contracts).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:jira_product_configs).class_name('Jira::JiraProductConfig').dependent(:destroy) }
    it { is_expected.to have_one(:score_matrix).dependent(:destroy) }
    it { is_expected.to have_many(:product_users).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:product_users) }
  end

  context 'with validations' do
    context 'for simple ones' do
      it { is_expected.to validate_presence_of :name }
    end

    context 'for complex ones' do
      let(:customer) { Fabricate :customer }

      context 'for uniqueness' do
        context 'same name in same customer' do
          let(:company) { Fabricate :company }
          let!(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }
          let!(:other_product) { Fabricate.build :product, customer: customer, name: 'zzz' }

          it 'does not accept the model' do
            expect(other_product.valid?).to be false
            expect(other_product.errors[:name]).to eq ['Não deve repetir nome de produto para o mesmo cliente.']
          end
        end

        context 'different name in same customer' do
          let(:company) { Fabricate :company }
          let!(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }
          let!(:other_product) { Fabricate.build :product, company: company, customer: customer, name: 'aaa' }

          it { expect(other_product.valid?).to be true }
        end

        context 'same name in different customer' do
          let(:company) { Fabricate :company }
          let!(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }
          let!(:other_product) { Fabricate.build :product, name: 'zzz' }

          it { expect(other_product.valid?).to be true }
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
  end

  RSpec.shared_context 'context with no demands' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :executing }
    let!(:waiting_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :waiting }
    let!(:finished_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :finished }
    let!(:cancelled_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now, customers: [customer], products: [product], status: :cancelled }
  end

  RSpec.shared_context 'consolidations variables data for product', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company, name: 'zzz' }
    let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'ccc' }

    let(:other_product) { Fabricate :product, company: company, name: 'aaa' }

    let!(:project) { Fabricate :project, start_date: Time.zone.local(2018, 10, 17, 10, 0, 0), end_date: Time.zone.local(2018, 12, 5, 10, 0, 0), customers: [product.customer], products: [product], value: 15_000, qty_hours: 5000, hour_value: 2.5 }
    let!(:nil_value_project) { Fabricate :project, start_date: Time.zone.local(2018, 10, 17, 10, 0, 0), customers: [product.customer], products: [product], status: :executing, value: nil }
    let!(:other_project) { Fabricate :project, start_date: Time.zone.local(2018, 10, 17, 10, 0, 0), end_date: 3.weeks.from_now, customers: [product.customer], products: [product], value: 5000, qty_hours: 10_000, hour_value: 2 }
    let!(:other_product_project) { Fabricate :project, customers: [other_product.customer], products: [other_product], start_date: Time.zone.local(2018, 10, 17, 10, 0, 0), end_date: Time.zone.local(2018, 12, 5, 10, 0, 0), value: 22_000, qty_hours: 50_000, hour_value: 0.44 }

    let!(:first_demand) { Fabricate :demand, product: product, project: project, created_date: Time.zone.local(2018, 11, 14, 10, 0, 0), end_date: nil, effort_downstream: 900, effort_upstream: 50 }
    let!(:second_demand) { Fabricate :demand, product: product, project: project, created_date: Time.zone.local(2018, 11, 14, 10, 0, 0), end_date: Time.zone.now, effort_downstream: 900, effort_upstream: 50 }
    let!(:third_demand) { Fabricate :demand, product: product, portfolio_unit: portfolio_unit, project: project, created_date: Time.zone.local(2018, 11, 14, 10, 0, 0), end_date: Time.zone.now, effort_downstream: 900, effort_upstream: 50 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations variables data for product'
    it { expect(product.avg_hours_per_demand).to eq 950.0 }
  end

  describe '#remaining_backlog_count' do
    include_context 'consolidations variables data for product'
    it { expect(product.remaining_backlog_count).to eq 1 }
  end

  describe '#percentage_remaining_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.percentage_remaining_scope).to eq 0.3333333333333333 }
  end

  describe '#total_flow_pressure' do
    it 'computes the pressure' do
      travel_to Time.zone.local(2018, 11, 14, 10) do
        company = Fabricate :company
        product = Fabricate :product, company: company, name: 'zzz'

        project = Fabricate :project, start_date: Time.zone.local(2018, 10, 17, 10), end_date: Time.zone.local(2018, 12, 5, 10), customers: [product.customer], products: [product]
        other_project = Fabricate :project, start_date: Time.zone.local(2018, 10, 15, 10), end_date: Time.zone.local(2018, 12, 18, 10), customers: [product.customer], products: [product], status: :executing
        Fabricate :project, start_date: Time.zone.local(2018, 10, 20, 10), end_date: 3.weeks.from_now, customers: [product.customer], products: [product], value: 5000, qty_hours: 10_000

        Fabricate :demand, product: product, project: project, created_date: Time.zone.local(2018, 11, 14, 10), end_date: nil
        Fabricate :demand, product: product, project: other_project, created_date: Time.zone.local(2018, 11, 19, 10), end_date: Time.zone.now
        Fabricate :demand, product: product, project: project, created_date: Time.zone.local(2018, 11, 20, 10), end_date: nil

        expect(product.total_flow_pressure).to be_within(0.00001).of(0.05882)
      end
    end
  end

  describe '#delivered_scope' do
    include_context 'consolidations variables data for product'
    it { expect(product.delivered_scope).to eq 2 }
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
      it { expect(product.total_cost).to eq 7125 }
    end
  end

  describe '#total_hours' do
    context 'with no demands' do
      include_context 'context with no demands'
      it { expect(product.total_hours).to eq 0 }
    end

    context 'with demands' do
      include_context 'consolidations variables data for product'
      it { expect(product.total_hours).to eq 2850 }
    end
  end

  describe '#score_matrix_questions' do
    let(:product) { Fabricate :product }

    context 'with score matrix in the product' do
      let(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }
      let!(:other_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }

      it { expect(product.score_matrix_questions).to match_array [score_matrix_question, other_score_matrix_question] }
    end

    context 'without score matrix in the product' do
      it { expect(product.score_matrix_questions).to eq [] }
    end
  end

  describe '#start_date' do
    context 'with projects' do
      it 'gets the sooner project start date' do
        product = Fabricate :product

        Fabricate :project, products: [product], start_date: 2.days.ago
        project = Fabricate :project, products: [product], start_date: 3.days.ago

        expect(product.start_date).to eq project.start_date
      end
    end

    context 'without projects' do
      it 'returns the creation date' do
        product = Fabricate :product

        expect(product.start_date).to eq product.created_at.to_date
      end
    end
  end

  describe '#end_date' do
    context 'with projects' do
      it 'gets the later project end date' do
        product = Fabricate :product

        Fabricate :project, products: [product], end_date: 2.days.ago
        project = Fabricate :project, products: [product], end_date: 3.days.ago

        expect(product.end_date).to eq project.end_date
      end
    end

    context 'without projects' do
      it 'returns today' do
        travel_to Time.zone.local(2022, 12, 7, 10) do
          product = Fabricate :product

          expect(product.end_date).to eq Time.zone.today
        end
      end
    end
  end

  describe '#add_user' do
    let(:user) { Fabricate :user }

    context 'when the product does not have the user yet' do
      let(:product) { Fabricate :product }

      before { product.add_user(user) }

      it { expect(product.reload.users).to eq [user] }
    end

    context 'when the product has the user' do
      let(:product) { Fabricate :product, users: [user] }

      before { product.add_user(user) }

      it { expect(product.reload.users).to eq [user] }
    end
  end
end
