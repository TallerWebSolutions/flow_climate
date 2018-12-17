# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with(waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4, negotiating: 5) }
    it { is_expected.to define_enum_for(:project_type).with(outsourcing: 0, consulting: 1, training: 2, domestic_product: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :team }

    it { is_expected.to have_many(:project_risk_configs).dependent(:destroy) }
    it { is_expected.to have_many(:project_risk_alerts).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:destroy) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
    it { is_expected.to have_many(:stage_project_configs) }
    it { is_expected.to have_many(:stages).through(:stage_project_configs) }
    it { is_expected.to have_many(:integration_errors).dependent(:destroy) }
    it { is_expected.to have_many(:project_change_deadline_histories).dependent(:destroy) }
    it { is_expected.to have_one(:project_jira_config).dependent(:destroy) }

    it { is_expected.to have_many(:user_project_roles).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_project_roles) }
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
      it { is_expected.to validate_presence_of :percentage_effort_to_bugs }
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
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }
    let!(:demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
    let!(:other_demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
    it { expect(project.consumed_hours.to_f).to eq 420 }
  end

  describe '#remaining_money' do
    context 'having hour_value' do
      let(:project) { Fabricate :project, qty_hours: 1000, value: 100_000, hour_value: 100 }
      let!(:demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
      let!(:other_demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }

      it { expect(project.remaining_money.to_f).to eq 58_000.0 }
    end
    context 'having no hour_value' do
      let(:project) { Fabricate :project, start_date: 4.months.ago, qty_hours: 1000, value: 100_000, hour_value: nil }
      let!(:demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
      let!(:other_demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
      it { expect(project.remaining_money.to_f).to eq 58_000.0 }
    end
  end

  describe '#percentage_remaining_money' do
    context 'total_days is higher than 0' do
      let(:project) { Fabricate :project, start_date: 4.months.ago, qty_hours: 1000, value: 100_000, hour_value: 100 }
      it { expect(project.percentage_remaining_money).to eq((project.remaining_money / project.value) * 100) }
    end
    context 'value is 0' do
      let(:project) { Fabricate :project, value: 0 }
      it { expect(project.percentage_remaining_money).to eq 0 }
    end
  end

  describe '#current_team' do
    let(:product_team) { Fabricate :team }
    let(:project_team) { Fabricate :team }
    let(:team) { Fabricate :team }
    let(:other_team) { Fabricate :team }

    context 'having a defined team to the project' do
      let(:product) { Fabricate :product, team: product_team }
      let(:project) { Fabricate :project, product: product, team: project_team, end_date: 4.weeks.from_now }
      let!(:project_jira_config) { Fabricate :project_jira_config, project: project, team: other_team }

      it { expect(project.current_team).to eq project_team }
    end

    context 'having no data' do
      context 'but having a team to the product' do
        let(:product) { Fabricate :product, team: product_team }
        let!(:project) { Fabricate :project, product: product }
        let!(:project_jira_config) { Fabricate :project_jira_config, project: project, team: team }

        it { expect(project.current_team).to eq product_team }
      end
      context 'having no team to the product but having a configuration to Jira' do
        let(:product) { Fabricate :product, team: nil }
        let(:project) { Fabricate :project, product: product, project_type: :outsourcing }
        let!(:project_jira_config) { Fabricate :project_jira_config, project: project, team: team }

        it { expect(project.current_team).to eq team }
      end
      context 'having no team to the product and no configuration to Jira' do
        let(:product) { Fabricate :product, team: nil }
        let(:project) { Fabricate :project, product: product, project_type: :outsourcing }

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
        let!(:opened_bugs) { Fabricate.times(20, :demand, project: project, demand_type: :bug, created_date: Time.zone.parse('2018-03-05 22:00')) }
        let!(:opened_features) { Fabricate.times(10, :demand, project: project, demand_type: :feature, created_date: Time.zone.parse('2018-03-06 22:00')) }
        let!(:delivered_bugs) { Fabricate.times(5, :demand, project: project, demand_type: :bug, created_date: Time.zone.parse('2018-03-05 22:00'), end_date: Time.zone.parse('2018-03-07 10:00')) }

        context 'specifying no date' do
          before { allow(Time.zone).to receive(:today) { Time.zone.parse('2018-03-06') } }
          it { expect(project.flow_pressure).to eq 32.5 }
        end
        context 'specifying a date' do
          it { expect(project.flow_pressure(Time.zone.parse('2018-03-05 22:00'))).to eq 21.666666666666668 }
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
        it { expect(project.flow_pressure).to be_within(0.01).of(project.backlog_remaining.to_f / project.remaining_days.to_f) }
      end
      context 'having no results' do
        it { expect(project.flow_pressure).to eq 30 }
      end
    end
  end

  describe '#total_bugs_opened' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }

    context 'having demands' do
      let!(:opened_bugs) { Fabricate.times(20, :demand, project: project, demand_type: :bug) }
      let!(:opened_features) { Fabricate.times(10, :demand, project: project, demand_type: :feature) }
      let!(:delivered_bugs) { Fabricate.times(5, :demand, project: project, demand_type: :bug, end_date: 1.week.ago) }

      it { expect(project.total_bugs_opened).to eq 20 }
    end
    context 'having no demands' do
      it { expect(project.total_bugs_opened).to eq 0 }
    end
  end

  describe '#total_bugs_closed' do
    let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
    context 'having demands' do
      let!(:opened_bugs) { Fabricate.times(20, :demand, project: project, demand_type: :bug) }
      let!(:opened_features) { Fabricate.times(10, :demand, project: project, demand_type: :feature) }
      let!(:delivered_bugs) { Fabricate.times(5, :demand, project: project, demand_type: :bug, end_date: 1.week.ago) }

      it { expect(project.total_bugs_closed).to eq 5 }
    end
    context 'having no demands' do
      it { expect(project.total_bugs_closed).to eq 0 }
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

  describe '#risk_color' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }
    context 'having alerts' do
      let!(:risk_alert) { Fabricate :project_risk_alert, project: project, alert_color: :red, created_at: Time.zone.today }
      let!(:other_risk_alert) { Fabricate :project_risk_alert, project: project, alert_color: :green, created_at: 1.day.ago }
      it { expect(project.risk_color).to eq 'red' }
    end
    context 'having no alerts' do
      it { expect(project.risk_color).to eq 'green' }
    end
  end

  RSpec.shared_context 'demands with effort', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 100, hour_value: 10, monthly_payment: 1200, total_monthly_payment: 1300 }
    let!(:project) { Fabricate :project, team: team, customer: customer, start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 3000, value: 400_000, hour_value: 200, percentage_effort_to_bugs: 100 }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: project, stage: third_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, project: project, created_date: 1.week.ago, end_date: 2.days.ago }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: 1.month.ago, last_time_out: 3.weeks.ago }

    let!(:third_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.today }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.today }

    let!(:fifth_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: 2.months.ago, last_time_out: 5.weeks.ago }
  end

  describe '#total_throughput' do
    context 'having results' do
      include_context 'demands with effort'
      it { expect(project.total_throughput).to eq 3 }
    end
    context 'having no results' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
      it { expect(project.total_throughput).to eq 0 }
    end
  end

  describe '#total_hours_bug' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_bug.to_f).to eq 72.6 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
      it { expect(project.total_hours_bug).to eq 0 }
    end
  end

  describe '#avg_hours_per_demand' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.avg_hours_per_demand).to eq 77.0 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
      it { expect(project.avg_hours_per_demand).to eq 0 }
    end
  end

  describe '#avg_hours_per_demand_upstream' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }
    context 'having results' do
      include_context 'demands with effort'
      it { expect(project.avg_hours_per_demand_upstream).to eq 118.8 }
    end
    context 'having no results' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
      it { expect(project.avg_hours_per_demand_upstream).to eq 0 }
    end
  end

  describe '#last_week_scope' do
    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.last_week_scope).to eq 32 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 65, end_date: 4.weeks.from_now }
      it { expect(project.last_week_scope).to eq 65 }
    end
  end

  describe '#total_throughput_upstream' do
    context 'having results' do
      include_context 'demands with effort'
      it { expect(project.total_throughput_upstream).to match_array [third_demand] }
    end
    context 'having no results' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
      it { expect(project.total_throughput_upstream).to eq [] }
    end
  end

  describe '#avg_hours_per_demand_downstream' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.avg_hours_per_demand_downstream).to eq 56.1 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }
      it { expect(project.avg_hours_per_demand_downstream).to eq 0 }
    end
  end

  describe '#backlog_remaining' do
    context 'having demands' do
      context 'specifying no date' do
        include_context 'demands with effort'
        it { expect(project.backlog_remaining).to eq 32 }
      end
      context 'specifying a date' do
        include_context 'demands with effort'
        it { expect(project.backlog_remaining(2.weeks.ago)).to eq 32 }
      end
    end
    context 'having no demands' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }
      it { expect(project.backlog_remaining).to eq project.initial_scope }
    end
  end

  describe '#backlog_for' do
    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.backlog_for(1.week.ago)).to eq 33 }
      it { expect(project.backlog_for(2.weeks.ago)).to eq 32 }
      it { expect(project.backlog_for).to eq 33 }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      it { expect(project.backlog_for(1.week.ago)).to eq 30 }
    end
  end

  describe '#total_throughput_downstream' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_throughput_downstream).to match_array [first_demand, second_demand] }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }
      it { expect(project.total_throughput_downstream).to eq [] }
    end
  end

  describe '#total_hours_upstream' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_upstream).to eq 118.8 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }
      it { expect(project.total_hours_upstream).to eq 0 }
    end
  end

  describe '#total_hours_downstream' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_downstream.to_f).to eq 112.2 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }
      it { expect(project.total_hours_downstream).to eq 0 }
    end
  end

  describe '#total_hours_consumed' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_consumed.to_f).to eq 231.0 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }
      it { expect(project.total_hours_consumed).to eq 0 }
    end
  end

  describe '#remaining_hours' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.remaining_hours.to_f).to eq 2769.0 }
    end
    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }
      it { expect(project.remaining_hours).to eq 5000 }
    end
  end

  describe '#required_hours' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.required_hours).to eq 2464.0 }
    end
    context 'having no data' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      it { expect(project.required_hours).to eq 0 }
    end
  end

  describe '#required_hours_per_available_hours' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.required_hours_per_available_hours).to eq 0.8898519321054532 }
    end
    context 'having no data' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      it { expect(project.required_hours_per_available_hours).to eq 0 }
    end
  end

  describe '#backlog_unit_growth' do
    context 'having data for last week and 2 weeks ago' do
      include_context 'demands with effort'
      it { expect(project.backlog_unit_growth).to eq 1 }
    end

    context 'having no data to required weeks' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      it { expect(project.backlog_unit_growth).to eq 0 }
    end
  end

  describe '#total_throughput_for' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_throughput_for(Time.zone.today)).to eq 2 }
    end
    context 'having no result' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      it { expect(project.total_throughput_for(1.week.ago)).to eq 0 }
    end
  end

  describe '#backlog_growth_rate' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.backlog_growth_rate).to eq 0.03125 }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, start_date: 2.months.ago, end_date: 3.months.from_now }

      it { expect(project.backlog_growth_rate).to eq 0 }
    end
  end

  describe '#money_per_deadline' do
    before { travel_to Date.new(2018, 11, 19) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.money_per_deadline.to_f).to eq 3804.3010752688174 }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, start_date: 1.week.ago, initial_scope: 30, end_date: 3.weeks.from_now, value: 10_000, hour_value: 20 }
      it { expect(project.money_per_deadline.to_f).to eq 454.54545454545456 }
    end
  end

  describe '#backlog_growth_throughput_rate' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }
    after { travel_back }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.backlog_growth_throughput_rate).to eq 0.5 }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      it { expect(project.backlog_growth_throughput_rate).to eq 0 }
    end
  end

  describe '#current_cost' do
    context 'having cost' do
      include_context 'demands with effort'
      it { expect(project.current_cost).to eq 0.22e4 }
    end
    context 'having no cost yet' do
      let(:project) { Fabricate :project, end_date: 4.weeks.from_now }
      it { expect(project.current_cost).to eq 0 }
    end
  end

  describe '#last_alert_for' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }
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

  describe '#red?' do
    let(:first_risk_config) { Fabricate :project_risk_config, project: project, risk_type: :no_money_to_deadline }
    let(:second_risk_config) { Fabricate :project_risk_config, project: project, risk_type: :backlog_growth_rate }

    context 'having a red alert as the last alert for the project' do
      let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.days.from_now }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :red, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: project, alert_color: :green, created_at: 1.hour.ago }

      it { expect(project.red?).to be true }
    end
    context 'having a green alert as the last alert for the project' do
      let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.days.from_now }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :green, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :red, created_at: 1.hour.ago }

      it { expect(project.red?).to be false }
    end
    context 'having a green alert as one type and a red as another type' do
      let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.days.from_now }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: project, alert_color: :green, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: project, alert_color: :red, created_at: 1.hour.ago }

      it { expect(project.red?).to be true }
    end

    context 'having no alerts' do
      let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.days.from_now }

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
    let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }

    context 'having data for last week' do
      let!(:opened_bugs) { Fabricate.times(20, :demand, project: project, demand_type: :bug, created_date: 1.week.ago) }
      let!(:opened_features) { Fabricate.times(10, :demand, project: project, demand_type: :feature, created_date: 3.weeks.ago) }
      let!(:delivered_bugs) { Fabricate.times(5, :demand, project: project, demand_type: :bug, created_date: 2.weeks.ago, end_date: 1.week.ago) }
      let!(:delivered_features) { Fabricate.times(14, :demand, project: project, demand_type: :feature, created_date: 2.weeks.ago, end_date: 2.weeks.ago) }

      it { expect(project.total_throughput_until(2.weeks.ago)).to eq 14 }
    end

    context 'having no data' do
      it { expect(project.total_throughput_until(1.week.ago)).to eq 0 }
    end
  end

  describe '#percentage_of_demand_type' do
    let(:project) { Fabricate :project }
    context 'the chore type' do
      context 'when there is no chores' do
        let!(:bug_demand) { Fabricate :demand, demand_type: :bug, project: project }
        let!(:feature_demand) { Fabricate :demand, demand_type: :feature, project: project }

        it { expect(project.percentage_of_demand_type(:chore)).to eq 0 }
      end
      context 'when there is no demands' do
        it { expect(project.percentage_of_demand_type(:chore)).to eq 0 }
      end
      context 'when there is chores' do
        let!(:feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:other_feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:chore_demand) { Fabricate :demand, demand_type: :chore, project: project }
        let!(:bug_demand) { Fabricate :demand, demand_type: :bug, project: project }

        it { expect(project.percentage_of_demand_type(:chore)).to eq 25 }
      end
    end
    context 'the feature type' do
      context 'when there is no features' do
        let!(:bug_demand) { Fabricate :demand, demand_type: :bug, project: project }
        let!(:chore_demand) { Fabricate :demand, demand_type: :chore, project: project }

        it { expect(project.percentage_of_demand_type(:feature)).to eq 0 }
      end
      context 'when there is no demands' do
        it { expect(project.percentage_of_demand_type(:feature)).to eq 0 }
      end
      context 'when there is features' do
        let!(:feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:other_feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:chore_demand) { Fabricate :demand, demand_type: :chore, project: project }
        let!(:bug_demand) { Fabricate :demand, demand_type: :bug, project: project }

        it { expect(project.percentage_of_demand_type(:feature)).to eq 50 }
      end
    end
    context 'the bug type' do
      context 'when there is no bugs' do
        let!(:feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:chore_demand) { Fabricate :demand, demand_type: :chore, project: project }

        it { expect(project.percentage_of_demand_type(:bug)).to eq 0 }
      end
      context 'when there is no demands' do
        it { expect(project.percentage_of_demand_type(:bug)).to eq 0 }
      end
      context 'when there is bugs' do
        let!(:feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:other_feature_demand) { Fabricate :demand, demand_type: :feature, project: project }
        let!(:chore_demand) { Fabricate :demand, demand_type: :chore, project: project }
        let!(:bug_demand) { Fabricate :demand, demand_type: :bug, project: project }

        it { expect(project.percentage_of_demand_type(:bug)).to eq 25 }
      end
    end
  end

  describe '#average_block_duration' do
    let(:project) { Fabricate :project }

    context 'having blocks' do
      let(:demand) { Fabricate :demand, demand_type: :bug, project: project }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, discarded_at: 1.day.ago, block_duration: 100 }
      let!(:demand_block) { Fabricate :demand_block, demand: demand, block_duration: 10 }
      let!(:other_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 20 }

      it { expect(project.average_block_duration).to eq 15 }
    end
    context 'having no demands' do
      it { expect(project.average_block_duration).to eq 0 }
    end
    context 'having no valid blocks' do
      let(:demand) { Fabricate :demand, demand_type: :bug, project: project }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, discarded_at: 1.day.ago, block_duration: 100 }

      it { expect(project.average_block_duration).to eq 0 }
    end
  end

  describe '#leadtime_for_class_of_service' do
    let(:project) { Fabricate :project }

    context 'having demands' do
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, end_date: Time.zone.today, leadtime: 100 }
      let!(:other_expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, end_date: Time.zone.today, leadtime: 80 }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project, end_date: Time.zone.today, leadtime: 80 }
      it { expect(project.leadtime_for_class_of_service(:expedite).to_f).to eq 96.0 }
      it { expect(project.leadtime_for_class_of_service(:expedite, 60).to_f).to eq 92.0 }
    end
    context 'having no demands' do
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, end_date: Time.zone.today, leadtime: 100 }
      let!(:other_expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, end_date: Time.zone.today, leadtime: 80 }

      it { expect(project.leadtime_for_class_of_service(:standard)).to eq 0 }
    end
  end

  describe '#leadtime_for_demand_type' do
    let(:project) { Fabricate :project }

    context 'having demands' do
      let!(:expedite_demand) { Fabricate :demand, demand_type: :bug, project: project, end_date: Time.zone.today, leadtime: 100 }
      let!(:other_expedite_demand) { Fabricate :demand, demand_type: :bug, project: project, end_date: Time.zone.today, leadtime: 80 }
      let!(:standard_demand) { Fabricate :demand, demand_type: :feature, project: project, end_date: Time.zone.today, leadtime: 80 }
      it { expect(project.leadtime_for_demand_type(:bug).to_f).to eq 96.0 }
      it { expect(project.leadtime_for_demand_type(:bug, 60).to_f).to eq 92.0 }
    end
    context 'having no demands' do
      let!(:expedite_demand) { Fabricate :demand, demand_type: :bug, project: project, end_date: Time.zone.today, leadtime: 100 }
      let!(:other_expedite_demand) { Fabricate :demand, demand_type: :bug, project: project, end_date: Time.zone.today, leadtime: 80 }

      it { expect(project.leadtime_for_demand_type(:feature)).to eq 0 }
    end
  end

  describe '#active_and_kept_blocks' do
    let(:project) { Fabricate :project }
    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having blocks' do
      let!(:inactive_demand_block) { Fabricate :demand_block, demand: demand, active: false, discarded_at: nil }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, discarded_at: Time.zone.yesterday }
      let!(:inactive_and_discarded_demand_block) { Fabricate :demand_block, demand: demand, active: false, discarded_at: Time.zone.yesterday }
      let!(:active_demand_block) { Fabricate :demand_block, demand: demand, active: true, discarded_at: nil }
      let!(:other_active_demand_block) { Fabricate :demand_block, demand: demand, active: true, discarded_at: nil }

      it { expect(project.active_and_kept_blocks).to eq [active_demand_block, other_active_demand_block] }
    end

    context 'having no active and not discarded blocks' do
      let!(:inactive_demand_block) { Fabricate :demand_block, demand: demand, active: false, discarded_at: nil }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, discarded_at: Time.zone.yesterday }
      let!(:inactive_and_discarded_demand_block) { Fabricate :demand_block, demand: demand, active: false, discarded_at: Time.zone.yesterday }

      it { expect(project.active_and_kept_blocks).to eq [] }
    end

    context 'having no blocks' do
      it { expect(project.active_and_kept_blocks).to eq [] }
    end
  end

  describe '#percentage_expedite' do
    let(:project) { Fabricate :project }
    context 'when there is no expedites' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }

      it { expect(project.percentage_expedite).to eq 0 }
    end
    context 'when there is no demands' do
      it { expect(project.percentage_expedite).to eq 0 }
    end
    context 'when there is expedites' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project }

      it { expect(project.percentage_expedite).to eq 25 }
    end
  end

  describe '#percentage_standard' do
    let(:project) { Fabricate :project }
    context 'when there is no standards' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }

      it { expect(project.percentage_standard).to eq 0 }
    end
    context 'when there is no demands' do
      it { expect(project.percentage_standard).to eq 0 }
    end
    context 'when there is standard' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project }

      it { expect(project.percentage_standard).to eq 25 }
    end
  end

  describe '#percentage_intangible' do
    let(:project) { Fabricate :project }
    context 'when there is no intangibles' do
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }

      it { expect(project.percentage_intangible).to eq 0 }
    end
    context 'when there is no demands' do
      it { expect(project.percentage_intangible).to eq 0 }
    end
    context 'when there is intangible' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project }

      it { expect(project.percentage_intangible).to eq 25 }
    end
  end

  describe '#percentage_fixed_date' do
    let(:project) { Fabricate :project }
    context 'when there is no fixed_dates' do
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }

      it { expect(project.percentage_fixed_date).to eq 0 }
    end
    context 'when there is no demands' do
      it { expect(project.percentage_fixed_date).to eq 0 }
    end
    context 'when there is fixed dates' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project }

      it { expect(project.percentage_fixed_date).to eq 25 }
    end
  end

  describe '#kept_demands_ids' do
    let(:project) { Fabricate :project }

    context 'having demands' do
      let!(:demand) { Fabricate :demand, project: project }
      let!(:other_demand) { Fabricate :demand, project: project }

      let!(:other_project_demand) { Fabricate :demand }

      let!(:not_kept_demand) { Fabricate :demand, project: project, discarded_at: Time.zone.today }

      it { expect(project.kept_demands_ids).to match_array [demand.id, other_demand.id] }
    end

    context 'having no demands' do
      let(:not_kept_demand) { Fabricate :demand, project: project, discarded_at: Time.zone.today }

      it { expect(project.kept_demands_ids).to match_array [] }
    end
  end

  describe '#add_user' do
    context 'when already has the user' do
      let(:user) { Fabricate :user }
      let!(:project) { Fabricate :project }
      before { project.add_user(user) }
      it { expect(project.users).to eq [user] }
    end
    context 'when does not have the user' do
      let(:user) { Fabricate :user }
      let!(:project) { Fabricate :project }
      before { project.add_user(user) }
      it { expect(project.users).to eq [user] }
    end
  end
end
