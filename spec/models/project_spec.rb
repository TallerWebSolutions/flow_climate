# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with(waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4, negotiating: 5) }
    it { is_expected.to define_enum_for(:project_type).with(outsourcing: 0, consulting: 1, training: 2, domestic_product: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many(:project_results).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:project_risk_configs).dependent(:destroy) }
    it { is_expected.to have_many(:project_risk_alerts).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:stage_project_configs) }
    it { is_expected.to have_many(:stages).through(:stage_project_configs) }
    it { is_expected.to have_one(:pipefy_config).dependent(:destroy) }
    it { is_expected.to have_many(:integration_errors).dependent(:destroy) }
    it { is_expected.to have_many(:project_change_deadline_histories).dependent(:destroy) }
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

      context 'the product cannot be blank to outsourcing projects' do
        context 'when is outsourcing and the product is blank' do
          let(:project) { Fabricate.build :project, project_type: :outsourcing, product: nil }
          it 'fails the validation' do
            expect(project.valid?).to be false
            expect(project.errors.full_messages).to eq ['Produto é obrigatório para projeto de outsourcing']
          end
        end

        context 'when is outsourcing and the product is present' do
          let(:project) { Fabricate.build :project, project_type: :outsourcing }
          it { expect(project.valid?).to be true }
        end

        context 'when it is consulting' do
          let(:project) { Fabricate :project, project_type: :consulting, product: nil }
          it { expect(project.valid?).to be true }
        end

        context 'when it is consulting' do
          let(:project) { Fabricate :project, project_type: :training, product: nil }
          it { expect(project.valid?).to be true }
        end
      end

      context 'uniqueness' do
        context 'name to product' do
          let(:customer) { Fabricate :customer }
          let(:product) { Fabricate :product, customer: customer }
          context 'same name in same product' do
            let!(:project) { Fabricate :project, customer: customer, product: product, name: 'zzz' }
            let!(:other_project) { Fabricate.build :project, customer: customer, product: product, name: 'zzz' }
            it 'does not accept the model' do
              expect(other_project.valid?).to be false
              expect(other_project.errors[:name]).to eq ['Não deve repetir nome de projeto para o mesmo produto.']
            end
          end
          context 'different name in same product' do
            let!(:project) { Fabricate :project, customer: customer, product: product, name: 'zzz' }
            let!(:other_project) { Fabricate.build :project, customer: customer, product: product, name: 'aaa' }
            it { expect(other_project.valid?).to be true }
          end
          context 'same name in other product' do
            let!(:project) { Fabricate :project, customer: customer, product: product, name: 'zzz' }
            let!(:other_project) { Fabricate.build :project, name: 'zzz' }
            it { expect(other_project.valid?).to be true }
          end
        end
        context 'nickname to customer' do
          let(:customer) { Fabricate :customer }
          context 'same name in same product' do
            let!(:project) { Fabricate :project, customer: customer, nickname: 'zzz' }
            let!(:other_project) { Fabricate.build :project, customer: customer, nickname: 'zzz' }
            it 'does not accept the model' do
              expect(other_project.valid?).to be false
              expect(other_project.errors[:nickname]).to eq ['Não deve repetir para o mesmo cliente']
            end
          end
          context 'different name in same product' do
            let!(:project) { Fabricate :project, customer: customer, nickname: 'zzz' }
            let!(:other_project) { Fabricate.build :project, customer: customer, nickname: 'aaa' }
            it { expect(other_project.valid?).to be true }
          end
          context 'same name in other product' do
            let!(:project) { Fabricate :project, customer: customer, nickname: 'zzz' }
            let!(:other_project) { Fabricate.build :project, nickname: 'zzz' }
            it { expect(other_project.valid?).to be true }
          end
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
    it { is_expected.to delegate_method(:company).to(:customer) }
  end

  context 'scopes' do
    let!(:first_project) { Fabricate :project, status: :waiting, start_date: Time.zone.today }
    let!(:second_project) { Fabricate :project, status: :waiting, start_date: Time.zone.today }
    let!(:third_project) { Fabricate :project, status: :executing, end_date: Time.zone.today }
    let!(:fourth_project) { Fabricate :project, status: :maintenance, end_date: Time.zone.today }
    let!(:fifth_project) { Fabricate :project, status: :cancelled, end_date: Time.zone.today }
    let!(:sixth_project) { Fabricate :project, status: :finished, end_date: Time.zone.today }

    let!(:first_pipefy_config) { Fabricate :pipefy_config, project: first_project }
    let!(:second_pipefy_config) { Fabricate :pipefy_config, project: second_project }

    describe '.waiting_projects_starting_within_week' do
      it { expect(Project.waiting_projects_starting_within_week).to match_array [first_project, second_project] }
    end

    describe '.running_projects_finishing_within_week' do
      it { expect(Project.running_projects_finishing_within_week).to match_array [third_project, fourth_project] }
    end

    describe '.running' do
      it { expect(Project.running).to match_array [third_project, fourth_project] }
    end

    describe '.active' do
      it { expect(Project.active).to match_array [first_project, second_project, third_project, fourth_project] }
    end

    describe '.no_pipefy_config' do
      it { expect(Project.no_pipefy_config).to match_array [third_project, fourth_project, fifth_project, sixth_project] }
    end
  end

  describe '#total_days' do
    let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
    it { expect(project.total_days).to eq 3 }
  end

  describe '#remaining_days' do
    context 'when the end date is in the future' do
      let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
      it { expect(project.remaining_days).to eq 2 }
    end
    context 'when the end date is in the past' do
      let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 1.day.ago }
      it { expect(project.remaining_days).to eq 0 }
    end
    context 'when the start date is in the future' do
      let(:project) { Fabricate :project, start_date: 2.days.from_now, end_date: 3.days.from_now }
      it { expect(project.remaining_days).to eq 2 }
    end
    context 'passing from_date as parameter' do
      let(:project) { Fabricate :project, start_date: 2.days.from_now, end_date: 10.days.from_now }
      it { expect(project.remaining_days(1.week.from_now.to_date)).to eq 4 }
    end
  end

  describe '#percentage_remaining_days' do
    context 'total_days is higher than 0' do
      let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }
      it { expect(project.percentage_remaining_days).to be_within(0.01).of(66.66) }
    end
    context 'the start and end days are in the same date' do
      let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today }
      it { expect(project.percentage_remaining_days).to eq 100 }
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

  describe '#percentage_remaining_money' do
    context 'total_days is higher than 0' do
      let(:project) { Fabricate :project, qty_hours: 1000, value: 100_000, hour_value: 100 }
      let!(:result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, qty_hours_upstream: 0, qty_hours_downstream: 20 }
      it { expect(project.percentage_remaining_money).to eq((project.remaining_money / project.value) * 100) }
    end
    context 'value is 0' do
      let(:project) { Fabricate :project, value: 0 }
      it { expect(project.percentage_remaining_money).to eq 0 }
    end
  end

  describe '#last_week_scope' do
    let(:project) { Fabricate :project, initial_scope: 65 }
    context 'having data in the week' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 3.weeks.ago, known_scope: 5 }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago, known_scope: 10 }
      let!(:third_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 20 }
      it { expect(project.last_week_scope).to eq 20 }
    end
    context 'having no data in the week but in the previous' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 3.weeks.ago, known_scope: 5 }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 10 }
      it { expect(project.last_week_scope).to eq 10 }
    end
  end

  describe '#penultimate_week_scope' do
    let(:project) { Fabricate :project, initial_scope: 65 }
    context 'having data in the week' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 3.weeks.ago, known_scope: 5 }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago, known_scope: 10 }
      let!(:third_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.penultimate_week_scope).to eq 10 }
    end
    context 'having no data in the week but in the previous' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 3.weeks.ago, known_scope: 5 }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.penultimate_week_scope).to eq 5 }
    end
  end

  describe '#current_team' do
    context 'having teams' do
      let(:product_team) { Fabricate :team }
      let(:product) { Fabricate :product, team: product_team }
      let(:project) { Fabricate :project, product: product }
      let(:team) { Fabricate :team }
      let(:other_team) { Fabricate :team }
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10, team: team }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20, team: other_team }
      it { expect(project.current_team).to eq other_team }
    end
    context 'having no results' do
      context 'but having a team to the product' do
        let(:team) { Fabricate :team }
        let(:product) { Fabricate :product, team: team }
        let!(:project) { Fabricate :project, product: product }
        it { expect(project.current_team).to eq team }
      end
      context 'having no team to the product' do
        let(:project) { Fabricate :project, project_type: :consulting, product: nil }
        it { expect(project.current_team).to be_nil }
      end
    end
  end

  describe '#update_team_in_product' do
    context 'having teams' do
      let(:product_team) { Fabricate :team }
      let(:product) { Fabricate :product, team: product_team }
      let(:project) { Fabricate :project, product: product }
      let(:team) { Fabricate :team }
      before { project.update_team_in_product(team) }
      it { expect(product.reload.team).to eq team }
    end
    context 'having no product' do
      let(:team) { Fabricate :team }
      let!(:project) { Fabricate :project, project_type: :consulting, product: nil }
      before { project.update_team_in_product(team) }
      it { expect { project.update_team_in_product(team) }.not_to raise_error(Exception) }
    end
  end

  describe '#flow_pressure' do
    context 'and the start and finish dates are in different days' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: Time.zone.parse('2018-03-05 22:00'), end_date: Time.zone.parse('2018-03-07 10:00') }
      context 'having results' do
        let!(:result) { Fabricate :project_result, project: project, result_date: Time.zone.parse('2018-03-05 23:00'), known_scope: 90, throughput_upstream: 4, throughput_downstream: 10 }
        let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.parse('2018-03-06 22:00'), known_scope: 70, throughput_upstream: 7, throughput_downstream: 13 }
        context 'specifying no date' do
          before { allow(Time.zone).to receive(:today) { Time.zone.parse('2018-03-06') } }
          it { expect(project.flow_pressure).to eq 18.0 }
        end
        context 'specifying a date' do
          it { expect(project.flow_pressure(Time.zone.parse('2018-03-05 22:00'))).to eq 12.0 }
        end
      end
      context 'having no results' do
        before { allow(Time.zone).to receive(:today) { Time.zone.parse('2018-03-06') } }
        it { expect(project.flow_pressure).to eq 15 }
      end
    end
    context 'and the start and finish dates are in the same day' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: Time.zone.today, end_date: Time.zone.today }
      context 'having results' do
        let!(:result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
        it { expect(project.flow_pressure).to be_within(0.01).of(project.total_gap.to_f / project.remaining_days.to_f) }
      end
      context 'having no results' do
        it { expect(project.flow_pressure).to eq 30 }
      end
    end
  end

  describe '#total_throughput' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput_upstream: 10, throughput_downstream: 20 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, throughput_upstream: 30, throughput_downstream: 25 }
      it { expect(project.total_throughput).to eq 85 }
    end
    context 'having no results' do
      it { expect(project.total_throughput).to eq 0 }
    end
  end

  describe '#total_throughput_upstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput_upstream: 10, throughput_downstream: 20 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, throughput_upstream: 30, throughput_downstream: 25 }
      it { expect(project.total_throughput_upstream).to eq 40 }
    end
    context 'having no results' do
      it { expect(project.total_throughput_upstream).to eq 0 }
    end
  end

  describe '#total_throughput_downstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput_upstream: 10, throughput_downstream: 20 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, throughput_upstream: 30, throughput_downstream: 25 }
      it { expect(project.total_throughput_downstream).to eq 45 }
    end
    context 'having no results' do
      it { expect(project.total_throughput_downstream).to eq 0 }
    end
  end

  describe '#total_hours_upstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
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
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_hours_downstream).to eq result.qty_hours_downstream + other_result.qty_hours_downstream }
    end
    context 'having no results' do
      it { expect(project.total_hours_downstream).to eq 0 }
    end
  end

  describe '#total_hours_consumed' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.total_hours_consumed).to eq result.project_delivered_hours + other_result.project_delivered_hours }
    end
    context 'having no results' do
      it { expect(project.total_hours_consumed).to eq 0 }
    end
  end

  describe '#remaining_hours' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 20 }
      it { expect(project.remaining_hours).to eq project.qty_hours - project.total_hours_consumed }
    end
    context 'having no results' do
      it { expect(project.remaining_hours).to eq project.qty_hours }
    end
  end

  describe '#total_bugs_opened' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
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
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
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
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
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
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
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
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput_upstream: 10, throughput_downstream: 20, qty_hours_downstream: 230, qty_hours_upstream: 456 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, throughput_upstream: 30, throughput_downstream: 25, qty_hours_downstream: 652, qty_hours_upstream: 324 }
      it { expect(project.avg_hours_per_demand).to eq 19.55294117647059 }
    end
    context 'having no results' do
      it { expect(project.avg_hours_per_demand).to eq 0 }
    end
  end

  describe '#avg_hours_per_demand_upstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput_upstream: 10, throughput_downstream: 20, qty_hours_downstream: 230, qty_hours_upstream: 456 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, throughput_upstream: 30, throughput_downstream: 25, qty_hours_downstream: 652, qty_hours_upstream: 324 }
      it { expect(project.avg_hours_per_demand_upstream).to eq 19.5 }
    end
    context 'having no results' do
      it { expect(project.avg_hours_per_demand_upstream).to eq 0 }
    end
  end

  describe '#avg_hours_per_demand_downstream' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput_upstream: 10, throughput_downstream: 20, qty_hours_downstream: 230, qty_hours_upstream: 456 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, throughput_upstream: 30, throughput_downstream: 25, qty_hours_downstream: 652, qty_hours_upstream: 324 }
      it { expect(project.avg_hours_per_demand_downstream).to eq 19.6 }
    end
    context 'having no results' do
      it { expect(project.avg_hours_per_demand_downstream).to eq 0 }
    end
  end

  describe '#total_gap' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
    context 'having results' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 40, throughput_upstream: 4, throughput_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 70, throughput_upstream: 7, throughput_downstream: 11 }
      context 'specifying no date' do
        it { expect(project.total_gap).to eq 38 }
      end
      context 'specifying a date' do
        it { expect(project.total_gap(1.week.ago)).to eq 26 }
      end
    end
    context 'having result to last week' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.week.ago, known_scope: 30, throughput_upstream: 4, throughput_downstream: 19 }
      it { expect(project.total_gap).to eq 7 }
    end
    context 'having no results' do
      it { expect(project.total_gap).to eq project.initial_scope }
    end
  end

  describe '#full_name' do
    context 'having product' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
      it { expect(project.full_name).to eq "#{project.customer_name} | #{project.product_name} | #{project.name}" }
    end
    context 'having no product' do
      let(:project) { Fabricate :project, project_type: :consulting, product: nil, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
      it { expect(project.full_name).to eq "#{project.customer_name} | #{project.name}" }
    end
  end

  describe '#required_hours' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let!(:first_project) { Fabricate :project, customer: customer, product: product, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
    context 'having results' do
      it { expect(first_project.required_hours).to eq first_project.total_gap * first_project.avg_hours_per_demand }
    end
    context 'having no results' do
      context 'but having results to the product' do
        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, product: product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: customer, product: product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, known_scope: 20 }

        it { expect(first_project.required_hours).to eq first_project.initial_scope * product.avg_hours_per_demand }
      end
      context 'but having results to the customer' do
        let(:other_product) { Fabricate :product, customer: customer }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, known_scope: 20 }

        it { expect(first_project.required_hours).to eq first_project.initial_scope * customer.avg_hours_per_demand }
      end
      context 'but having results to the company' do
        let(:other_customer) { Fabricate :customer, company: company }
        let(:other_product) { Fabricate :product, customer: other_customer }

        let!(:second_project) { Fabricate :project, initial_scope: 100, customer: other_customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:third_project) { Fabricate :project, initial_scope: 100, customer: other_customer, product: other_product, start_date: 1.week.ago, end_date: 1.week.from_now }
        let!(:result) { Fabricate :project_result, project: second_project, result_date: 1.day.ago, known_scope: 10 }
        let!(:other_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today, known_scope: 20 }

        it { expect(first_project.required_hours).to eq first_project.initial_scope * company.avg_hours_per_demand }
      end
    end
  end

  describe '#required_hours_per_available_hours' do
    let!(:first_project) { Fabricate :project }

    context 'having data' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.day.ago, known_scope: 10 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 20 }

      it { expect(first_project.required_hours_per_available_hours).to eq first_project.required_hours.to_f / first_project.remaining_hours.to_f }
    end
    context 'having no data' do
      it { expect(first_project.required_hours_per_available_hours).to eq 0 }
    end
  end

  describe '#risk_color' do
    let(:project) { Fabricate :project }
    context 'having alerts' do
      let!(:risk_alert) { Fabricate :project_risk_alert, project: project, alert_color: :red, created_at: Time.zone.today }
      let!(:other_risk_alert) { Fabricate :project_risk_alert, project: project, alert_color: :green, created_at: 1.day.ago }
      it { expect(project.risk_color).to eq 'red' }
    end
    context 'having no alerts' do
      it { expect(project.risk_color).to eq 'green' }
    end
  end

  describe '#backlog_unit_growth' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having data for last week and 2 weeks ago' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 110, throughput_upstream: 20, throughput_downstream: 10 }
      let!(:second_result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago, known_scope: 80, throughput_upstream: 10, throughput_downstream: 1 }

      it { expect(first_project.backlog_unit_growth).to eq 30 }
    end

    context 'having no data to required weeks' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80 }
      it { expect(first_project.backlog_unit_growth).to eq 0 }
    end
  end

  describe '#backlog_growth_rate' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having data for last week and 2 weeks ago' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 110, throughput_upstream: 20, throughput_downstream: 6 }
      let!(:second_result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago, known_scope: 80, throughput_upstream: 10, throughput_downstream: 7 }

      it { expect(first_project.backlog_growth_rate).to be_within(0.01).of(0.375) }
    end

    context 'having data for last week and 3 weeks ago' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 110, throughput_upstream: 20, throughput_downstream: 50 }
      let!(:second_result) { Fabricate :project_result, project: first_project, result_date: 3.weeks.ago, known_scope: 80, throughput_upstream: 10, throughput_downstream: 23 }

      it { expect(first_project.backlog_growth_rate).to be_within(0.01).of(0.375) }
    end

    context 'having no data to required weeks' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80 }

      it { expect(first_project.backlog_growth_rate).to eq 0 }
    end
  end

  describe '#backlog_for' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having data for last week' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80 }

      it { expect(first_project.backlog_for(1.week.ago)).to eq 110 }
    end

    context 'having data for 2 weeks ago' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago, known_scope: 110 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80 }
      context 'specifying the date' do
        it { expect(first_project.backlog_for(1.week.ago)).to eq 30 }
      end
      context 'specifying no date' do
        it { expect(first_project.backlog_for).to eq 80 }
      end
    end

    context 'having no result' do
      it { expect(first_project.backlog_for(1.week.ago)).to eq 30 }
    end
  end

  describe '#total_throughput_for' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having data for last week' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110, throughput_upstream: 20, throughput_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, throughput_upstream: 25, throughput_downstream: 12 }

      it { expect(first_project.total_throughput_for(Time.zone.today)).to eq 37 }
    end

    context 'having data for 2 weeks ago' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago, known_scope: 110, throughput_upstream: 20, throughput_downstream: 15 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, throughput_upstream: 25, throughput_downstream: 2 }

      it { expect(first_project.total_throughput_for(1.week.ago)).to eq 0 }
    end

    context 'having no result' do
      it { expect(first_project.total_throughput_for(1.week.ago)).to eq 0 }
    end
  end

  describe '#money_per_deadline' do
    let!(:first_project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 3.weeks.from_now, value: 10_000, hour_value: 20 }

    context 'having data for last week' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110, qty_hours_downstream: 200, qty_hours_upstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, qty_hours_downstream: 50, qty_hours_upstream: 5 }

      it { expect(first_project.money_per_deadline.to_f).to be_within(0.01).of(1.61) }
    end

    context 'having data for 2 weeks ago' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago, known_scope: 110, qty_hours_downstream: 200, qty_hours_upstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, qty_hours_downstream: 50, qty_hours_upstream: 5 }

      it { expect(first_project.money_per_deadline.to_f).to be_within(0.01).of(1.61) }
    end

    context 'having no result' do
      it { expect(first_project.money_per_deadline.to_f).to be_within(0.01).of(0.75) }
    end
  end

  describe '#backlog_growth_throughput_rate' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having data for last week and 2 weeks ago' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 110, throughput_upstream: 20, throughput_downstream: 10 }
      let!(:second_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 80, throughput_upstream: 10, throughput_downstream: 27 }

      it { expect(first_project.backlog_growth_throughput_rate).to eq 1.0 }
    end

    context 'having no data to required weeks' do
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, throughput_upstream: 25, throughput_downstream: 1 }
      it { expect(first_project.backlog_growth_throughput_rate).to eq 0 }
    end
  end

  describe '#last_alert_for' do
    let(:project) { Fabricate :project }
    let(:first_risk_config) { Fabricate :project_risk_config, risk_type: :no_money_to_deadline }
    let(:second_risk_config) { Fabricate :project_risk_config, risk_type: :flow_pressure }
    let(:third_risk_config) { Fabricate :project_risk_config, risk_type: :not_enough_available_hours }
    let!(:first_risk_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, created_at: 1.day.ago }
    let!(:second_risk_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, created_at: Time.zone.today }
    let!(:third_risk_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: project, created_at: Time.zone.today }

    context 'having alerts' do
      it { expect(project.last_alert_for(first_risk_config.risk_type)).to eq second_risk_alert }
    end
    context 'having no alerts to the type' do
      it { expect(project.last_alert_for(third_risk_config.risk_type)).to eq nil }
    end
  end

  describe '#average_demand_cost' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having project_result and throughput' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110, cost_in_month: 400, throughput_upstream: 20, throughput_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, cost_in_month: 400, throughput_upstream: 25, throughput_downstream: 1 }

      it { expect(first_project.average_demand_cost.to_f).to be_within(0.01).of(7.14) }
    end

    context 'having no project_result' do
      it { expect(first_project.average_demand_cost.to_d).to eq 0 }
    end

    context 'having no throughput' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110, cost_in_month: 400, throughput_upstream: 0, throughput_downstream: 0 }
      it { expect(first_project.average_demand_cost.to_d).to eq 400 }
    end

    context 'having throughput 1' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110, cost_in_month: 400, throughput_upstream: 0, throughput_downstream: 1 }
      it { expect(first_project.average_demand_cost.to_d).to eq 400 }
    end
  end

  describe '#red?' do
    let(:first_risk_config) { Fabricate :project_risk_config, project: project, risk_type: :no_money_to_deadline }
    let(:second_risk_config) { Fabricate :project_risk_config, project: project, risk_type: :backlog_growth_rate }

    context 'having a red alert as the last alert for the project' do
      let(:project) { Fabricate :project, end_date: 3.days.from_now }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :red, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: project, alert_color: :green, created_at: 1.hour.ago }

      it { expect(project.red?).to be true }
    end
    context 'having a green alert as the last alert for the project' do
      let(:project) { Fabricate :project, end_date: 3.days.from_now }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :green, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :red, created_at: 1.hour.ago }

      it { expect(project.red?).to be false }
    end
    context 'having a green alert as one type and a red as another type' do
      let(:project) { Fabricate :project, end_date: 3.days.from_now }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :green, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: project, alert_color: :red, created_at: 1.hour.ago }

      it { expect(project.red?).to be true }
    end

    context 'having no alerts' do
      let(:project) { Fabricate :project, end_date: 3.days.from_now }

      it { expect(project.red?).to be false }
    end
  end

  describe '#hours_per_month' do
    let(:project) { Fabricate :project, qty_hours: 100, start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 5, 23) }
    it { expect(project.hours_per_month).to eq 32.25806451612903 }
  end

  describe '#money_per_month' do
    let(:project) { Fabricate :project, value: 100, start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 5, 23) }
    it { expect(project.money_per_month.to_f).to eq 32.25806451612903 }
  end

  describe '#total_throughput_until' do
    let!(:first_project) { Fabricate :project, initial_scope: 30 }

    context 'having data for last week' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, known_scope: 110, throughput_upstream: 20, throughput_downstream: 10 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, throughput_upstream: 25, throughput_downstream: 1 }

      it { expect(first_project.total_throughput_until(Time.zone.today)).to eq 56 }
    end

    context 'having data for 2 weeks ago' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago, known_scope: 110, throughput_upstream: 20, throughput_downstream: 19 }
      let!(:other_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.today, known_scope: 80, throughput_upstream: 25, throughput_downstream: 22 }

      it { expect(first_project.total_throughput_until(1.week.ago)).to eq 39 }
    end

    context 'having no result' do
      it { expect(first_project.total_throughput_until(1.week.ago)).to eq 0 }
    end
  end

  describe '#manual?' do
    let(:project) { Fabricate :project }
    context 'having integration' do
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project }
      it { expect(project.manual?).to be false }
    end
    context 'having no integration' do
      it { expect(project.manual?).to be true }
    end
  end

  describe '#current_cost' do
    let(:project) { Fabricate :project }

    context 'having project_result' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago, cost_in_month: 100 }
      let!(:other_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, cost_in_month: 150 }
      it { expect(project.current_cost).to eq 150 }
    end
    context 'having no project_result' do
      it { expect(project.current_cost).to eq 0 }
    end
  end
end
