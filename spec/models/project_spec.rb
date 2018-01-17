# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with(waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4) }
    it { is_expected.to define_enum_for(:project_type).with(outsourcing: 0, consulting: 1, training: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to have_many :project_results }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :customer }
      it { is_expected.to validate_presence_of :project_type }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :status }
      it { is_expected.to validate_presence_of :start_date }
      it { is_expected.to validate_presence_of :end_date }
      it { is_expected.to validate_presence_of :status }
      it { is_expected.to validate_presence_of :initial_scope }
      it { is_expected.to validate_presence_of :qty_hours }
    end
    context 'complex ones' do
      context 'values' do
        context 'with both value and hour value null' do
          let(:project) { Fabricate.build :project, value: nil, hour_value: nil }
          it 'fails the validation' do
            expect(project.valid?).to be false
            expect(project.errors.full_messages).to eq ['Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
          end
        end
        context 'with both value and hour value null' do
          let(:project) { Fabricate.build :project, value: 10, hour_value: nil }
          it { expect(project.valid?).to be true }
        end
        context 'with both value and hour value null' do
          let(:project) { Fabricate.build :project, value: nil, hour_value: 10 }
          it { expect(project.valid?).to be true }
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
  end

  describe '#total_days' do
    let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
    it { expect(project.total_days).to eq 2 }
  end

  describe '#remaining_days' do
    context 'when the end date is in the future' do
      let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
      it { expect(project.remaining_days).to eq 1 }
    end
    context 'when the end date is in the past' do
      let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 1.day.ago }
      it { expect(project.remaining_days).to eq 0 }
    end
    context 'when the start date is in the future' do
      let(:project) { Fabricate :project, start_date: 2.days.from_now, end_date: 3.days.from_now }
      it { expect(project.remaining_days).to eq 0 }
    end
  end

  describe '#consumed_hours' do
    let(:project) { Fabricate :project }
    let!(:result) { Fabricate :project_result, project: project }
    let!(:other_result) { Fabricate :project_result, project: project }
    it { expect(project.consumed_hours).to eq result.project_delivered_hours + other_result.project_delivered_hours }
  end

  describe '#remaining_money' do
    context 'having hour_value' do
      let(:project) { Fabricate :project, qty_hours: 1000, value: 100_000, hour_value: 100 }
      let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 20 }
      it { expect(project.remaining_money.to_f).to eq 97_000 }
    end
    context 'having no hour_value' do
      let(:project) { Fabricate :project, qty_hours: 1000, value: 100_000, hour_value: nil }
      let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 20 }
      it { expect(project.remaining_money.to_f).to eq 97_000 }
    end
  end

  describe '#red?' do
    context 'when it is executing' do
      let(:project) { Fabricate :project, status: :executing, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
      context 'when there is less money than time remaining' do
        let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 400 }
        let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 300 }
        it { expect(project.red?).to be true }
      end
      context 'when there is more money than time remaining' do
        let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 1 }
        let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 2 }
        it { expect(project.red?).to be false }
      end
    end
    context 'when it is waiting' do
      let(:project) { Fabricate :project, status: :waiting, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
      context 'when there is less money than time remaining' do
        let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 400 }
        let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 300 }
        it { expect(project.red?).to be false }
      end
    end
    context 'when it is finished' do
      let(:project) { Fabricate :project, status: :finished, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
      context 'when there is less money than time remaining' do
        let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 400 }
        let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 300 }
        it { expect(project.red?).to be false }
      end
    end
    context 'when it is cancelled' do
      let(:project) { Fabricate :project, status: :cancelled, qty_hours: 1000, value: 100_000, hour_value: 100, start_date: 1.day.ago, end_date: 1.month.from_now }
      context 'when there is less money than time remaining' do
        let!(:result) { Fabricate :project_result, project: project, qty_hours_downstream: 400 }
        let!(:other_result) { Fabricate :project_result, project: project, qty_hours_downstream: 300 }
        it { expect(project.red?).to be false }
      end
    end
  end

  describe '#current_backlog' do
    let(:project) { Fabricate :project }
    let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
    let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
    it { expect(project.current_backlog).to eq 20 }
  end

  describe '#current_team' do
    let(:project) { Fabricate :project }
    context 'having teams' do
      let(:team) { Fabricate :team }
      let(:other_team) { Fabricate :team }
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10, team: team }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20, team: other_team }
      it { expect(project.current_team).to eq other_team }
    end
    context 'having no results' do
      it { expect(project.current_team).to be_nil }
    end
  end
end
