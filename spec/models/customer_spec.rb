# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :projects }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :name }
  end

  describe '#active_projects' do
    let(:customer) { Fabricate :customer }
    let!(:active_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:other_active_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, status: :cancelled }

    it { expect(customer.active_projects).to match_array [active_project, other_active_project] }
  end

  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let!(:active_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end
  describe '#waiting_projects' do
    let(:customer) { Fabricate :customer }
    let!(:active_project) { Fabricate :project, customer: customer, status: :executing }
    let!(:waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:other_waiting_project) { Fabricate :project, customer: customer, status: :waiting }
    let!(:finished_project) { Fabricate :project, customer: customer, status: :finished }
    let!(:cancelled_project) { Fabricate :project, customer: customer, status: :cancelled }

    it { expect(customer.waiting_projects).to match_array [waiting_project, other_waiting_project] }
  end

  describe 'red_projects' do
    let(:customer) { Fabricate :customer }
    let(:project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
    let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 400 }
    let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 300 }
    it { expect(customer.red_projects).to eq [project] }
  end
end
