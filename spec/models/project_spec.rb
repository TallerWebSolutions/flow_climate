# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with(waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4) }
    it { is_expected.to define_enum_for(:project_type).with(outsourcing: 0, consulting: 1, training: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many :project_results }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :customer }
      it { is_expected.to validate_presence_of :product }
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

      context 'the customer in the project must be the same of in the product' do
        let(:customer) { Fabricate :customer }
        let(:other_customer) { Fabricate :customer }
        let(:product) { Fabricate :product, customer: customer }

        context 'when they are not the same' do
          let(:project) { Fabricate.build :project, customer: other_customer, product: product }
          it 'fails the validation' do
            expect(project.valid?).to be false
            expect(project.errors.full_messages).to eq ['Customer O cliente do projeto deve ser o mesmo cliente do produto']
          end
        end

        context 'when they are the same' do
          let(:project) { Fabricate :project, customer: customer, product: product }
          it { expect(project.valid?).to be true }
        end

        context 'having no product' do
          let(:project) { Fabricate :project, customer: customer }
          it { expect(project.valid?).to be true }
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
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
      it { expect(project.remaining_days).to eq 1 }
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
      let!(:result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 20 }
      it { expect(project.remaining_money.to_f).to eq 97_000 }
    end
    context 'having no hour_value' do
      let(:project) { Fabricate :project, qty_hours: 1000, value: 100_000, hour_value: nil }
      let!(:result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 20 }
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
        let!(:result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 1 }
        let!(:other_result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 2 }
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

  describe '#flow_pressure' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.flow_pressure).to be_within(0.01).of(project.total_gap.to_f / project.remaining_days.to_f) }
    end
    context 'having no results' do
      it { expect(project.flow_pressure).to eq 5 }
    end
  end

  describe '#total_throughput' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_throughput).to eq result.throughput + other_result.throughput }
    end
    context 'having no results' do
      it { expect(project.total_throughput).to eq 0 }
    end
  end

  describe '#total_hours_upstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_hours_upstream).to eq result.qty_hours_upstream + other_result.qty_hours_upstream }
    end
    context 'having no results' do
      it { expect(project.total_hours_upstream).to eq 0 }
    end
  end

  describe '#total_hours_downstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_hours_downstream).to eq result.qty_hours_downstream + other_result.qty_hours_downstream }
    end
    context 'having no results' do
      it { expect(project.total_hours_downstream).to eq 0 }
    end
  end

  describe '#total_hours' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_hours).to eq result.project_delivered_hours + other_result.project_delivered_hours }
    end
    context 'having no results' do
      it { expect(project.total_hours).to eq 0 }
    end
  end

  describe '#total_bugs_opened' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_bugs_opened).to eq result.qty_bugs_opened + other_result.qty_bugs_opened }
    end
    context 'having no results' do
      it { expect(project.total_bugs_opened).to eq 0 }
    end
  end

  describe '#total_bugs_closed' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_bugs_closed).to eq result.qty_bugs_closed + other_result.qty_bugs_closed }
    end
    context 'having no results' do
      it { expect(project.total_bugs_closed).to eq 0 }
    end
  end

  describe '#total_hours_bug' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_hours_bug).to eq result.qty_hours_bug + other_result.qty_hours_bug }
    end
    context 'having no results' do
      it { expect(project.total_hours_bug).to eq 0 }
    end
  end

  describe '#avg_leadtime' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.avg_leadtime).to eq((result.leadtime + other_result.leadtime) / 2) }
    end
    context 'having no results' do
      it { expect(project.avg_leadtime).to eq nil }
    end
  end

  describe '#avg_hours_per_demand' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.from_now, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.avg_hours_per_demand).to eq(project.total_hours.to_f / project.total_throughput.to_f) }
    end
    context 'having no results' do
      it { expect(project.avg_hours_per_demand).to eq 0 }
    end
  end

  describe '#total_gap' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_gap).to eq project.current_backlog - project.total_throughput }
    end
    context 'having no results' do
      it { expect(project.total_gap).to eq project.initial_scope }
    end
  end

  describe '#full_name' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
    it { expect(project.full_name).to eq "#{project.customer_name} | #{project.product_name} | #{project.name}" }
  end
end
