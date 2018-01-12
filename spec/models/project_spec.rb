# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with(waiting: 0, executing: 1, finished: 2, cancelled: 3) }
    it { is_expected.to define_enum_for(:project_type).with(outsourcing: 0, consulting: 1, training: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to have_many :project_results }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :end_date }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :initial_scope }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
  end

  describe '#total_days' do
    let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
    it { expect(project.total_days).to eq 2 }
  end

  describe '#remaining_days' do
    let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
    it { expect(project.remaining_days).to eq 1 }
  end

  describe '#consumed_hours' do
    let(:project) { Fabricate :project }
    let!(:result) { Fabricate :project_result, project: project }
    let!(:other_result) { Fabricate :project_result, project: project }
    it { expect(project.consumed_hours).to eq result.total_hours_consumed + other_result.total_hours_consumed }
  end
end
