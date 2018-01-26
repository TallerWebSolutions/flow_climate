# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :products }
    it { is_expected.to have_many :projects }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :name }
  end

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let!(:active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
    let!(:other_active_project) { Fabricate :project, customer: customer, product: product, status: :executing }
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

  describe '#red_projects' do
    let(:customer) { Fabricate :customer }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 400 }
    let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 300 }
    it { expect(customer.red_projects).to eq [project] }
  end

  RSpec.shared_context 'consolidations variables data for customer', shared_context: :metadata do
    let(:customer) { Fabricate :customer }
    let(:other_customer) { Fabricate :customer }

    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let(:other_product) { Fabricate :product, customer: other_customer, name: 'zzz' }

    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:other_project) { Fabricate :project, customer: customer, product: product }
    let(:other_customer_project) { Fabricate :project, customer: other_customer, product: other_product }

    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, result_date: 1.day.ago, known_scope: 50 }
  end

  describe '#current_backlog' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.current_backlog).to eq 25 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.avg_hours_per_demand).to eq customer.projects.sum(&:avg_hours_per_demand) / customer.projects_count.to_f }
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
    it { expect(customer.percentage_remaining_scope).to eq((customer.total_gap.to_f / customer.current_backlog.to_f) * 100) }
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.total_flow_pressure).to eq customer.projects.sum(&:flow_pressure) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations variables data for customer'
    it { expect(customer.delivered_scope).to eq customer.projects.sum(&:total_throughput) }
  end
end
