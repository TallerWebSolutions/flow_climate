# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4, negotiating: 5) }
    it { is_expected.to define_enum_for(:project_type).with_values(outsourcing: 0, consulting: 1, training: 2, domestic_product: 3, marketing: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to(:initiative).optional }

    it { is_expected.to have_many(:project_risk_configs).dependent(:destroy) }
    it { is_expected.to have_many(:project_risk_alerts).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:tasks).through(:demands) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
    it { is_expected.to have_many(:demand_efforts).through(:demands) }
    it { is_expected.to have_many(:memberships).through(:demands) }
    it { is_expected.to have_many(:team_members).through(:memberships) }
    it { is_expected.to have_many(:stage_project_configs) }
    it { is_expected.to have_many(:stages).through(:stage_project_configs) }
    it { is_expected.to have_many(:project_change_deadline_histories).dependent(:destroy) }
    it { is_expected.to have_many(:jira_project_configs).dependent(:destroy) }
    it { is_expected.to have_many(:flow_events).dependent(:destroy) }
    it { is_expected.to have_many(:project_consolidations).dependent(:destroy) }
    it { is_expected.to have_many(:replenishing_consolidations).dependent(:destroy) }
    it { is_expected.to have_many(:project_broken_wip_logs).dependent(:destroy) }

    it { is_expected.to have_many(:user_project_roles).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_project_roles) }

    it { is_expected.to have_many(:customers_projects).dependent(:destroy) }
    it { is_expected.to have_many(:customers).through(:customers_projects).dependent(:destroy) }
    it { is_expected.to have_many(:products_projects).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:products_projects).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :project_type }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :status }
      it { is_expected.to validate_presence_of :start_date }
      it { is_expected.to validate_presence_of :end_date }
      it { is_expected.to validate_presence_of :initial_scope }
      it { is_expected.to validate_presence_of :qty_hours }
      it { is_expected.to validate_presence_of :percentage_effort_to_bugs }
      it { is_expected.to validate_presence_of :max_work_in_progress }
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

        context 'with hour value null' do
          let(:project) { Fabricate.build :project, value: 10, hour_value: nil }

          it { expect(project.valid?).to be true }
        end

        context 'with value null' do
          let(:project) { Fabricate.build :project, value: nil, hour_value: 10 }

          it { expect(project.valid?).to be true }
        end
      end

      context 'uniqueness' do
        context 'name to company' do
          let(:company) { Fabricate :company }

          context 'same name in same product' do
            let!(:project) { Fabricate :project, company: company, name: 'zzz' }
            let!(:other_project) { Fabricate.build :project, company: company, name: 'zzz' }

            it 'does not accept the model' do
              expect(other_project.valid?).to be false
              expect(other_project.errors[:name]).to eq ['Não deve repetir nome de projeto para a mesma empresa.']
            end
          end

          context 'different name in same company' do
            let!(:project) { Fabricate :project, company: company, name: 'zzz' }
            let!(:other_project) { Fabricate.build :project, company: company, name: 'aaa' }

            it { expect(other_project.valid?).to be true }
          end

          context 'same name in other company' do
            let!(:project) { Fabricate :project, company: company, name: 'zzz' }
            let!(:other_project) { Fabricate.build :project, name: 'zzz' }

            it { expect(other_project.valid?).to be true }
          end
        end
      end
    end
  end

  context 'scopes' do
    before { travel_to Time.zone.local(2019, 10, 24, 10, 0, 0) }

    let!(:first_project) { Fabricate :project, status: :waiting, start_date: Time.zone.today, end_date: Time.zone.tomorrow }
    let!(:second_project) { Fabricate :project, status: :waiting, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:third_project) { Fabricate :project, status: :executing, start_date: 1.month.ago, end_date: 3.days.from_now }
    let!(:fourth_project) { Fabricate :project, status: :maintenance, start_date: 2.months.ago, end_date: Time.zone.today }
    let!(:fifth_project) { Fabricate :project, status: :cancelled, start_date: 1.week.ago, end_date: 1.day.ago }
    let!(:sixth_project) { Fabricate :project, status: :finished, start_date: 1.day.ago, end_date: Time.zone.today }

    let!(:seventh_project) { Fabricate :project, status: :executing, start_date: Time.zone.tomorrow, end_date: 3.days.from_now }

    describe '.waiting_projects_starting_within_week' do
      it { expect(described_class.waiting_projects_starting_within_week).to match_array [first_project, second_project] }
    end

    describe '.running_projects_finishing_within_week' do
      it { expect(described_class.running_projects_finishing_within_week).to match_array [third_project, fourth_project] }
    end

    describe '.running' do
      it { expect(described_class.running).to match_array [third_project, fourth_project] }
    end

    describe '.active' do
      it { expect(described_class.active).to match_array [first_project, third_project, fourth_project, seventh_project] }
    end

    describe '.not_cancelled' do
      it { expect(described_class.not_cancelled).to match_array [first_project, second_project, third_project, fourth_project, sixth_project, seventh_project] }
    end

    describe '.finishing_after' do
      it { expect(described_class.finishing_after(26.hours.ago)).to match_array [first_project, fourth_project, fifth_project, sixth_project, seventh_project, third_project] }
    end

    pending '.active_in_period'
  end

  describe '#to_hash' do
    context 'when it has consolidations' do
      it 'returns as project hash' do
        project = Fabricate :project
        Fabricate :project_consolidation, project: project, project_throughput_hours_in_month: 10, project_throughput_hours: 30, consolidation_date: Time.zone.today
        Fabricate :project_consolidation, project: project, project_throughput_hours_in_month: 20, project_throughput_hours: 40, consolidation_date: 1.day.ago

        expected = { id: project.id, name: project.name, start_date: project.start_date, end_date: project.end_date, remaining_backlog: project.remaining_backlog,
                     remaining_days: project.remaining_days, remaining_weeks: project.remaining_weeks, remaining_hours: project.remaining_hours,
                     produced_hours_in_current_month: 10, produced_hours_total: 30,
                     deadline_risk: project.current_risk_to_deadline.to_f,
                     deadline_risk_team_info: (project.last_project_consolidation&.team_based_operational_risk || 1), current_lead_time: project.last_project_consolidation&.lead_time_p80 }

        expect(project.to_hash).to eq expected
      end
    end

    context 'when it has no consolidations' do
      it 'returns as project hash' do
        project = Fabricate :project

        expected = { id: project.id, name: project.name, start_date: project.start_date, end_date: project.end_date, remaining_backlog: project.remaining_backlog,
                     remaining_days: project.remaining_days, remaining_weeks: project.remaining_weeks, remaining_hours: project.remaining_hours,
                     produced_hours_in_current_month: 0,
                     produced_hours_total: 0, deadline_risk: project.current_risk_to_deadline.to_f,
                     deadline_risk_team_info: (project.last_project_consolidation&.team_based_operational_risk || 1), current_lead_time: project.last_project_consolidation&.lead_time_p80 }

        expect(project.to_hash).to eq expected
      end
    end
  end

  describe '#total_days' do
    let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }

    it { expect(project.total_days).to be_within(0.1).of(3.9) }
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

      it { expect(project.remaining_days(1.week.from_now)).to eq 4 }
    end
  end

  describe '#remaining_weeks' do
    context 'when the end date is in the future' do
      let(:project) { Fabricate :project, start_date: 1.week.ago, end_date: 1.week.from_now }

      it { expect(project.remaining_weeks).to eq 2 }
    end

    context 'when the end date is in the past' do
      let(:project) { Fabricate :project, start_date: 2.weeks.ago, end_date: 1.week.ago }

      it { expect(project.remaining_weeks).to eq 0 }
    end

    context 'when the start date is in the future' do
      let(:project) { Fabricate :project, start_date: 2.weeks.from_now, end_date: 3.weeks.from_now }

      it { expect(project.remaining_weeks).to eq 2 }
    end

    context 'passing from_date as parameter' do
      let(:project) { Fabricate :project, start_date: 2.weeks.from_now, end_date: 10.weeks.from_now }

      it { expect(project.remaining_weeks(1.week.from_now.to_date)).to eq 9 }
    end
  end

  describe '#percentage_remaining_days' do
    before { travel_to Time.zone.local(2018, 9, 18, 10, 0, 0) }

    context 'total_days is higher than 0' do
      let(:project) { Fabricate :project, start_date: 1.day.ago, end_date: 1.day.from_now }

      it { expect(project.percentage_remaining_days).to eq 50 }
    end

    context 'the start and end days are in the same date' do
      let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today }

      it { expect(project.percentage_remaining_days).to eq 50 }
    end
  end

  describe '#consumed_hours_in_period' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }
    let!(:demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
    let!(:other_demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }

    it { expect(project.consumed_hours_in_period(project.start_date, 4.weeks.from_now).to_f).to eq 420 }
  end

  describe '#remaining_money' do
    context 'having hour_value' do
      let(:project) { Fabricate :project, qty_hours: 1000, value: 100_000, hour_value: 100 }
      let!(:other_project) { Fabricate :project, qty_hours: 1000, value: nil, hour_value: 100 }
      let!(:demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
      let!(:other_demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }

      let!(:nil_project_value_demand) { Fabricate :demand, project: other_project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }

      it { expect(project.remaining_money(2.weeks.ago).to_f).to eq 58_000.0 }
      it { expect(other_project.remaining_money(2.weeks.ago).to_f).to eq(-21_000.0) }
    end

    context 'having no hour_value' do
      let(:project) { Fabricate :project, start_date: 4.months.ago, qty_hours: 1000, value: 100_000, hour_value: nil }
      let!(:demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }
      let!(:other_demand) { Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: 2.weeks.ago }

      it { expect(project.remaining_money(2.weeks.ago).to_f).to eq 58_000.0 }
    end
  end

  describe '#flow_pressure' do
    context 'and the start and finish dates are in different days' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: Time.zone.parse('2018-03-05 22:00'), end_date: Time.zone.parse('2018-03-07 10:00') }

      context 'with demands' do
        context 'and specifying no date' do
          it 'returns the flow pressure based on date and remaining work' do
            travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
              team = Fabricate :team
              project = Fabricate :project, team: team, initial_scope: 20, start_date: 2.weeks.ago, end_date: 2.weeks.from_now

              first_stage = Fabricate :stage, teams: [team], projects: [project], order: 0
              second_stage = Fabricate :stage, teams: [team], projects: [project], order: 1

              first_demand = Fabricate :demand, project: project, team: team, created_date: 4.days.ago
              second_demand = Fabricate :demand, project: project, team: team, created_date: 3.days.ago
              third_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, commitment_date: 1.day.ago, end_date: 1.hour.ago
              fourth_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, discarded_at: 1.day.ago

              Fabricate :demand_transition, demand: first_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
              Fabricate :demand_transition, demand: second_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: nil
              Fabricate :demand_transition, demand: first_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
              Fabricate :demand_transition, demand: third_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
              Fabricate :demand_transition, demand: fourth_demand, stage: second_stage, last_time_in: 1.day.ago, last_time_out: nil

              expect(project.flow_pressure).to eq 1.2666666666666666
              expect(project.flow_pressure(Time.zone.parse('2018-03-05 22:00'))).to eq 1.1875
            end
          end
        end

        context 'and date negotiations' do
          it 'returns the pressure using the last valid deadline negotiated' do
            travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
              team = Fabricate :team
              project = Fabricate :project, initial_scope: 30, start_date: Time.zone.parse('2018-03-05 22:00'), end_date: Time.zone.parse('2018-03-12 10:00')

              Fabricate :project_change_deadline_history, project: project, created_at: Time.zone.parse('2018-03-07 11:00'), previous_date: Time.zone.parse('2018-03-05 10:00'), new_date: Time.zone.parse('2018-03-06 23:00')
              Fabricate :project_change_deadline_history, project: project, created_at: Time.zone.parse('2018-03-08 07:00'), previous_date: Time.zone.parse('2018-03-09 10:00'), new_date: Time.zone.parse('2018-03-10 22:00')
              Fabricate :project_change_deadline_history, project: project, created_at: Time.zone.parse('2018-03-09 05:00'), previous_date: Time.zone.parse('2018-03-10 22:00'), new_date: Time.zone.parse('2018-03-12 22:00')

              first_stage = Fabricate :stage, teams: [team], projects: [project], order: 0
              second_stage = Fabricate :stage, teams: [team], projects: [project], order: 1

              first_demand = Fabricate :demand, project: project, team: team, created_date: 4.days.ago
              second_demand = Fabricate :demand, project: project, team: team, created_date: 3.days.ago
              third_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, commitment_date: 1.day.ago, end_date: 1.hour.ago
              fourth_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, discarded_at: 1.day.ago

              Fabricate :demand_transition, demand: first_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
              Fabricate :demand_transition, demand: second_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: nil
              Fabricate :demand_transition, demand: first_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
              Fabricate :demand_transition, demand: third_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
              Fabricate :demand_transition, demand: fourth_demand, stage: second_stage, last_time_in: 1.day.ago, last_time_out: nil

              expect(project.flow_pressure).to eq 4.142857142857143
            end
          end
        end
      end

      context 'with no demands' do
        it 'returns the flow pressure based on initial scope' do
          travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
            project = Fabricate :project, start_date: 2.weeks.ago, end_date: 2.weeks.from_now, initial_scope: 10

            expect(project.flow_pressure).to eq 0.6666666666666666
          end
        end
      end
    end

    context 'and the start and finish dates are in the same day' do
      it 'computes the flow pressure using the day' do
        travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
          project = Fabricate :project, initial_scope: 30, start_date: Time.zone.today, end_date: Time.zone.today
          expect(project.flow_pressure).to eq 30
        end
      end
    end
  end

  describe '#relative_flow_pressure' do
    context 'and the start and finish dates are in different days' do
      context 'with demands' do
        it 'returns the flow pressure related to the given total' do
          travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
            team = Fabricate :team
            project = Fabricate :project, team: team, initial_scope: 20, start_date: 2.weeks.ago, end_date: 2.weeks.from_now

            first_stage = Fabricate :stage, teams: [team], projects: [project], order: 0
            second_stage = Fabricate :stage, teams: [team], projects: [project], order: 1

            first_demand = Fabricate :demand, project: project, team: team, created_date: 4.days.ago
            second_demand = Fabricate :demand, project: project, team: team, created_date: 3.days.ago
            third_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, commitment_date: 1.day.ago, end_date: 1.hour.ago
            fourth_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, discarded_at: 1.day.ago

            Fabricate :demand_transition, demand: first_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
            Fabricate :demand_transition, demand: second_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: nil
            Fabricate :demand_transition, demand: first_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
            Fabricate :demand_transition, demand: third_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
            Fabricate :demand_transition, demand: fourth_demand, stage: second_stage, last_time_in: 1.day.ago, last_time_out: nil

            expect(project.relative_flow_pressure(80)).to eq 1.583333333333333
          end
        end
      end

      context 'with no demands' do
        it 'returns the flow pressure based on initial scope' do
          travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
            project = Fabricate :project, start_date: 2.weeks.ago, end_date: 2.weeks.from_now
            expect(project.relative_flow_pressure(10)).to eq 20
          end
        end
      end

      context 'with no demands and no total pressure' do
        let(:project) { Fabricate :project }

        it { expect(project.relative_flow_pressure(nil)).to eq 0 }
      end

      context 'with no demands and 0 as total pressure' do
        let(:project) { Fabricate :project }

        it { expect(project.relative_flow_pressure(0)).to eq 0 }
      end
    end
  end

  describe '#relative_flow_pressure_in_replenishing_consolidation' do
    it 'returns the relative flow pressure in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 6.days.ago, relative_flow_pressure: 2.8
        Fabricate :replenishing_consolidation, project: project, consolidation_date: 5.days.ago, relative_flow_pressure: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, relative_flow_pressure: 0.2

        expect(project.relative_flow_pressure_in_replenishing_consolidation).to eq 0.2
        expect(project.relative_flow_pressure_in_replenishing_consolidation(6.days.ago)).to eq 2.8
      end
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
    let!(:team_member) { Fabricate :team_member, company: company, monthly_payment: 1300 }
    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 3.months.ago.to_date, end_date: nil }
    let!(:project) { Fabricate :project, team: team, customers: [customer], start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 3000, value: 1_000_000, hour_value: 200, percentage_effort_to_bugs: 100 }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: false }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: project, stage: first_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: project, stage: second_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: project, stage: third_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }

    let!(:first_demand) { Fabricate :demand, project: project, team: team, created_date: 2.weeks.ago, commitment_date: 8.days.ago, end_date: 1.week.ago, demand_type: :bug }
    let!(:second_demand) { Fabricate :demand, project: project, team: team, created_date: 2.weeks.ago, commitment_date: 9.days.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, project: project, team: team, created_date: 1.week.ago, commitment_date: 10.days.ago, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, project: project, team: team, created_date: Time.zone.now, commitment_date: Time.zone.now, end_date: nil }
    let!(:fifth_demand) { Fabricate :demand, project: project, team: team, created_date: 4.weeks.ago, commitment_date: nil, end_date: nil, discarded_at: 2.weeks.ago }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, membership: membership, start_time: 1.month.ago, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, membership: membership, start_time: 1.month.ago, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, membership: membership, start_time: 7.weeks.ago, finish_time: nil }
    let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: fourth_demand, membership: membership, start_time: 1.month.ago, finish_time: nil }

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

  describe '#avg_hours_per_demand' do
    before { travel_to Date.new(2018, 11, 19) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.avg_hours_per_demand).to eq 90.0 }
    end

    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now }

      it { expect(project.avg_hours_per_demand).to eq 0 }
    end
  end

  describe '#last_week_scope' do
    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.last_week_scope).to eq 28 }
    end

    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 65, end_date: 4.weeks.from_now }

      it { expect(project.last_week_scope).to eq 65 }
    end
  end

  describe '#remaining_backlog' do
    context 'with demands' do
      it 'returns the remaining backlog - not started work' do
        team = Fabricate :team
        project = Fabricate :project, team: team, initial_scope: 20

        first_stage = Fabricate :stage, teams: [team], projects: [project], order: 0
        second_stage = Fabricate :stage, teams: [team], projects: [project], order: 1

        first_demand = Fabricate :demand, project: project, team: team, created_date: 4.days.ago
        second_demand = Fabricate :demand, project: project, team: team, created_date: 3.days.ago
        third_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, commitment_date: 1.day.ago, end_date: 1.hour.ago
        fourth_demand = Fabricate :demand, project: project, team: team, created_date: 2.days.ago, discarded_at: 1.day.ago

        Fabricate :demand_transition, demand: first_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
        Fabricate :demand_transition, demand: second_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: nil
        Fabricate :demand_transition, demand: first_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
        Fabricate :demand_transition, demand: third_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
        Fabricate :demand_transition, demand: fourth_demand, stage: second_stage, last_time_in: 1.day.ago, last_time_out: nil

        expect(project.remaining_backlog).to eq 17
        expect(project.remaining_backlog(2.days.ago)).to eq 18
      end
    end

    context 'with no demands' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.week.ago, end_date: 1.week.from_now }

      it { expect(project.remaining_backlog).to eq project.initial_scope }
    end
  end

  describe '#percentage_remaining_work' do
    context 'with demands' do
      it 'returns the percentage of remaining work' do
        travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
          team = Fabricate :team
          project = Fabricate :project, team: team, initial_scope: 20

          first_stage = Fabricate :stage, teams: [team], projects: [project], order: 0
          second_stage = Fabricate :stage, teams: [team], projects: [project], order: 1

          first_demand = Fabricate :demand, project: project, team: team, created_date: 3.weeks.ago, commitment_date: 8.days.ago
          second_demand = Fabricate :demand, project: project, team: team, created_date: 3.weeks.ago, commitment_date: 9.days.ago
          third_demand = Fabricate :demand, project: project, team: team, created_date: 2.weeks.ago, commitment_date: 10.days.ago
          fourth_demand = Fabricate :demand, project: project, team: team, created_date: 2.weeks.ago, commitment_date: 10.days.ago
          Fabricate :demand, project: project, team: team, created_date: Time.zone.now, commitment_date: Time.zone.now, end_date: 2.days.ago
          Fabricate :demand, project: project, team: team, created_date: 4.weeks.ago, commitment_date: nil, end_date: nil, discarded_at: 2.weeks.ago

          Fabricate :demand_transition, demand: first_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
          Fabricate :demand_transition, demand: second_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: nil
          Fabricate :demand_transition, demand: first_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
          Fabricate :demand_transition, demand: third_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
          Fabricate :demand_transition, demand: fourth_demand, stage: second_stage, last_time_in: 1.day.ago, last_time_out: nil

          expect(project.percentage_remaining_work).to eq 0.9473684210526315
          expect(project.percentage_remaining_work(2.weeks.ago)).to eq 1
        end
      end
    end

    context 'with no demands' do
      let(:project) { Fabricate :project, initial_scope: 0, start_date: 1.week.ago, end_date: 1.week.from_now }

      it { expect(project.percentage_remaining_work).to eq 0 }
    end
  end

  describe '#total_hours_upstream' do
    before { travel_to Date.new(2018, 11, 19) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_upstream).to eq 150 }
    end

    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }

      it { expect(project.total_hours_upstream).to eq 0 }
    end
  end

  describe '#total_hours_downstream' do
    before { travel_to Date.new(2018, 11, 19) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_downstream.to_f).to eq 120 }
    end

    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }

      it { expect(project.total_hours_downstream).to eq 0 }
    end
  end

  describe '#total_hours_consumed' do
    before { travel_to Date.new(2018, 11, 19) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.total_hours_consumed.to_f).to eq 270 }
    end

    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }

      it { expect(project.total_hours_consumed).to eq 0 }
    end
  end

  describe '#remaining_hours' do
    before { travel_to Date.new(2018, 11, 19) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.remaining_hours.to_f).to eq 2730 }
    end

    context 'having no data' do
      let(:project) { Fabricate :project, initial_scope: 30, start_date: 1.day.ago, end_date: 1.week.from_now, qty_hours: 5000 }

      it { expect(project.remaining_hours).to eq 5000 }
    end
  end

  describe '#required_hours' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.required_hours).to eq 2250.0 }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }

      it { expect(project.required_hours).to eq 0 }
    end
  end

  describe '#required_hours_per_available_hours' do
    before { travel_to Date.new(2018, 11, 19) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.required_hours_per_available_hours).to be_within(0.02).of(0.82) }
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

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.backlog_growth_rate).to eq 0.03571428571428571 }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, start_date: 2.months.ago, end_date: 3.months.from_now }

      it { expect(project.backlog_growth_rate).to eq 0 }
    end
  end

  describe '#money_per_deadline' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }

    context 'having data' do
      include_context 'demands with effort'
      it { expect(project.money_per_deadline.to_f).to be_within(0.01).of(10_172.04) }
    end

    context 'having no data' do
      let!(:project) { Fabricate :project, start_date: 1.week.ago, initial_scope: 30, end_date: 3.weeks.from_now, value: 10_000, hour_value: 20 }

      it { expect(project.money_per_deadline.to_f).to be_within(8).of(454) }
    end
  end

  describe '#backlog_growth_throughput_rate' do
    before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }

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
    before { travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) }

    context 'having cost' do
      include_context 'demands with effort'
      it { expect(project.current_cost.to_f).to eq 54_000.0 }
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
      it { expect(project.last_alert_for(third_risk_config.risk_type)).to be_nil }
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

    it { expect(project.hours_per_month).to be_within(0.2).of(31.9) }
  end

  describe '#hours_per_day' do
    let(:project) { Fabricate :project, qty_hours: 100, start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 5, 23) }

    it { expect(project.hours_per_day).to be_within(0.01).of(1.06) }
  end

  describe '#money_per_month' do
    let(:project) { Fabricate :project, value: 100, start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 5, 23) }

    it { expect(project.money_per_month.to_f).to be_within(0.2).of(31.9) }
  end

  describe '#money_per_day' do
    let(:project) { Fabricate :project, value: 100, start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 5, 23) }

    it { expect(project.money_per_day.to_f).to be_within(0.01).of(1.06) }
  end

  describe '#total_throughput_until' do
    let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }

    context 'with data for last week' do
      it 'returns the TH to date' do
        team = Fabricate :team
        project = Fabricate :project, team: team, initial_scope: 20

        Fabricate :demand, project: project, team: team, created_date: 4.days.ago, end_date: nil
        Fabricate :demand, project: project, team: team, created_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, project: project, team: team, created_date: 3.days.ago, end_date: 2.days.ago, discarded_at: 1.day.ago
        Fabricate :demand, project: project, team: team, created_date: 2.days.ago, commitment_date: 1.day.ago, end_date: 1.hour.ago

        expect(project.total_throughput_until(1.day.ago)).to eq 1
        expect(project.total_throughput_until(30.hours.ago)).to eq 2
        expect(project.total_throughput_until(30.minutes.ago)).to eq 2
      end
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
    before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

    let(:project) { Fabricate :project }

    context 'having blocks' do
      let(:demand) { Fabricate :demand, demand_type: :bug, project: project }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, unblock_time: 1.day.from_now, discarded_at: 1.day.ago }
      let!(:demand_block) { Fabricate :demand_block, demand: demand, block_time: 1.day.ago, unblock_time: 1.day.from_now }
      let!(:other_demand_block) { Fabricate :demand_block, demand: demand, block_time: 1.day.ago, unblock_time: 2.days.from_now }

      it { expect(project.average_block_duration.to_f).to eq 8 }
    end

    context 'having no demands' do
      it { expect(project.average_block_duration).to eq 0 }
    end

    context 'having no valid blocks' do
      let(:demand) { Fabricate :demand, demand_type: :bug, project: project }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, discarded_at: 1.day.ago, block_working_time_duration: 100 }

      it { expect(project.average_block_duration).to eq 0 }
    end
  end

  describe '#leadtime_for_class_of_service' do
    before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

    let(:project) { Fabricate :project }

    context 'having demands' do
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, commitment_date: 2.days.ago, project: project, end_date: Time.zone.today }
      let!(:other_expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, commitment_date: 1.day.ago, end_date: Time.zone.today }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project, end_date: Time.zone.today, leadtime: 80 }

      it { expect(project.leadtime_for_class_of_service(:expedite).to_f).to eq 119_520.0 }
      it { expect(project.leadtime_for_class_of_service(:expedite, 60).to_f).to eq 102_240.0 }
    end

    context 'having no demands' do
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, end_date: Time.zone.today, leadtime: 100 }
      let!(:other_expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project, end_date: Time.zone.today, leadtime: 80 }

      it { expect(project.leadtime_for_class_of_service(:standard)).to eq 0 }
    end
  end

  describe '#general_leadtime' do
    before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

    let(:project) { Fabricate :project }

    context 'having demands' do
      let!(:expedite_demand) { Fabricate :demand, demand_type: :bug, project: project, commitment_date: 2.days.ago, end_date: Time.zone.today }
      let!(:other_expedite_demand) { Fabricate :demand, demand_type: :bug, project: project, commitment_date: 1.day.ago, end_date: Time.zone.today }
      let!(:standard_demand) { Fabricate :demand, demand_type: :feature, project: project, end_date: Time.zone.today }

      it { expect(project.general_leadtime.to_f).to eq 119_520.0 }
    end

    context 'having no demands' do
      it { expect(project.general_leadtime).to eq 0 }
    end
  end

  describe '#active_kept_closed_blocks' do
    let(:project) { Fabricate :project }
    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having blocks' do
      let!(:inactive_demand_block) { Fabricate :demand_block, demand: demand, active: false, unblock_time: 1.day.from_now, discarded_at: nil }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, unblock_time: 2.days.from_now, discarded_at: Time.zone.yesterday }
      let!(:inactive_and_discarded_demand_block) { Fabricate :demand_block, demand: demand, active: false, unblock_time: 1.day.from_now, discarded_at: Time.zone.yesterday }
      let!(:active_demand_block) { Fabricate :demand_block, demand: demand, active: true, unblock_time: 1.day.from_now, discarded_at: nil }
      let!(:other_active_demand_block) { Fabricate :demand_block, demand: demand, active: true, unblock_time: 1.day.from_now, discarded_at: nil }
      let!(:opened_active_demand_block) { Fabricate :demand_block, demand: demand, active: true, unblock_time: nil, discarded_at: nil }

      it { expect(project.active_kept_closed_blocks).to match_array [active_demand_block, other_active_demand_block] }
    end

    context 'having no active and not discarded blocks' do
      let!(:inactive_demand_block) { Fabricate :demand_block, demand: demand, active: false, discarded_at: nil }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, discarded_at: Time.zone.yesterday }
      let!(:inactive_and_discarded_demand_block) { Fabricate :demand_block, demand: demand, active: false, discarded_at: Time.zone.yesterday }

      it { expect(project.active_kept_closed_blocks).to eq [] }
    end

    context 'having no blocks' do
      it { expect(project.active_kept_closed_blocks).to eq [] }
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

  describe '#demands_of_class_of_service' do
    let(:project) { Fabricate :project }

    context 'when there is no expedites' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }

      it { expect(project.demands_of_class_of_service(:expedite)).to eq [] }
    end

    context 'when there is no demands' do
      it { expect(project.demands_of_class_of_service).to eq [] }
    end

    context 'when there is expedites' do
      let!(:intangible_demand) { Fabricate :demand, class_of_service: :intangible, project: project }
      let!(:fixed_date_demand) { Fabricate :demand, class_of_service: :fixed_date, project: project }
      let!(:standard_demand) { Fabricate :demand, class_of_service: :standard, project: project }
      let!(:expedite_demand) { Fabricate :demand, class_of_service: :expedite, project: project }

      it { expect(project.demands_of_class_of_service(:expedite)).to eq [expedite_demand] }
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

  describe '#add_user' do
    context 'when already has the user' do
      let(:user) { Fabricate :user }
      let!(:project) { Fabricate :project, users: [user] }

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

  describe '#add_customer' do
    let(:customer) { Fabricate :customer }

    context 'when the project does not have the customer yet' do
      let(:project) { Fabricate :project }

      before { project.add_customer(customer) }

      it { expect(project.reload.customers).to eq [customer] }
    end

    context 'when the project has the customer' do
      let(:project) { Fabricate :project, customers: [customer] }

      before { project.add_customer(customer) }

      it { expect(project.reload.customers).to eq [customer] }
    end
  end

  describe '#remove_customer' do
    let(:customer) { Fabricate :customer }

    context 'when the project does not have the customer yet' do
      let(:project) { Fabricate :project }

      before { project.remove_customer(customer) }

      it { expect(project.reload.customers).to eq [] }
    end

    context 'when the project has the customer' do
      let(:project) { Fabricate :project, customers: [customer] }

      before { project.remove_customer(customer) }

      it { expect(project.reload.customers).to eq [] }
    end
  end

  describe '#add_product' do
    let(:product) { Fabricate :product }

    context 'when the project does not have the product yet' do
      let(:project) { Fabricate :project }

      before { project.add_product(product) }

      it { expect(project.reload.products).to eq [product] }
    end

    context 'when the project has the product' do
      let(:project) { Fabricate :project, products: [product] }

      before { project.add_product(product) }

      it { expect(project.reload.products).to eq [product] }
    end
  end

  describe '#remove_product' do
    let(:product) { Fabricate :product }

    context 'when the project does not have the product yet' do
      let(:project) { Fabricate :project }

      before { project.remove_product(product) }

      it { expect(project.reload.products).to eq [] }
    end

    context 'when the project has the product' do
      let(:project) { Fabricate :project, products: [product] }

      before { project.remove_product(product) }

      it { expect(project.reload.products).to eq [] }
    end
  end

  describe '#aging' do
    context 'when already has the user' do
      let(:user) { Fabricate :user }
      let!(:project) { Fabricate :project, start_date: 4.days.ago.to_date, end_date: Time.zone.today }

      it { expect(project.aging).to eq 4 }
    end
  end

  describe '#aging_today' do
    let!(:project) { Fabricate :project, start_date: 4.days.ago.to_date, end_date: 1.day.from_now.to_date }

    it { expect(project.aging_today).to eq 4 }
  end

  describe '#current_risk_to_deadline' do
    context 'with project consolidations' do
      let(:project) { Fabricate :project, end_date: 2.weeks.from_now }
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, operational_risk: 10 }
      let!(:other_project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, operational_risk: 2 }

      it { expect(project.current_risk_to_deadline).to eq 10 }
    end

    context 'without project consolidations' do
      let(:project) { Fabricate :project }

      it { expect(project.current_risk_to_deadline).to eq 1 }
    end
  end

  describe '#tasks_based_current_risk_to_deadline' do
    context 'with project consolidations' do
      let(:project) { Fabricate :project, end_date: 2.weeks.from_now }
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, tasks_based_operational_risk: 10 }
      let!(:other_project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, tasks_based_operational_risk: 2 }

      it { expect(project.tasks_based_current_risk_to_deadline).to eq 10 }
    end

    context 'without project consolidations' do
      let(:project) { Fabricate :project }

      it { expect(project.tasks_based_current_risk_to_deadline).to eq 1 }
    end
  end

  describe '#consolidations_last_update' do
    context 'with project consolidations' do
      let(:project) { Fabricate :project }
      let(:consolidation_date_one_day) { 1.day.ago }
      let(:consolidation_date_two_days) { 2.days.ago }

      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: consolidation_date_one_day, updated_at: consolidation_date_one_day }
      let!(:other_project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: consolidation_date_two_days, updated_at: consolidation_date_two_days }

      it { expect(project.consolidations_last_update.to_date).to eq consolidation_date_one_day.to_date }
    end

    context 'without project consolidations' do
      let(:project) { Fabricate :project }

      it { expect(project.consolidations_last_update).to be_nil }
    end
  end

  describe '#failure_load' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:first_demand) { Fabricate :demand, project: project, demand_type: :feature, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 20, effort_upstream: 30 }
      let!(:second_demand) { Fabricate :demand, project: project, demand_type: :bug, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40, effort_upstream: 35 }
      let!(:third_demand) { Fabricate :demand, project: project, demand_type: :bug, created_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10, effort_upstream: 78 }

      it { expect(project.failure_load).to eq 66.66666666666666 }
    end

    context 'with no data' do
      it { expect(project.failure_load).to eq 0 }
    end
  end

  describe '#first_deadline' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now, qty_hours: 2000 }

    context 'with data' do
      let!(:project_change_deadline_history) { Fabricate :project_change_deadline_history, project: project, previous_date: 3.days.ago }
      let!(:other_project_change_deadline_history) { Fabricate :project_change_deadline_history, project: project, previous_date: 5.days.ago }

      it { expect(project.first_deadline).to eq other_project_change_deadline_history.previous_date }
    end

    context 'with no data' do
      it { expect(project.first_deadline).to eq project.end_date }
    end
  end

  describe '#days_difference_between_first_and_last_deadlines' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now, qty_hours: 2000 }

    context 'with data' do
      let!(:project_change_deadline_history) { Fabricate :project_change_deadline_history, project: project, previous_date: 3.days.ago }
      let!(:other_project_change_deadline_history) { Fabricate :project_change_deadline_history, project: project, previous_date: 5.days.ago }

      it { expect(project.days_difference_between_first_and_last_deadlines).to eq 33 }
    end

    context 'with no data' do
      it { expect(project.days_difference_between_first_and_last_deadlines).to eq 0 }
    end
  end

  describe '#total_weeks' do
    let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: 4.weeks.from_now, qty_hours: 2000 }

    it { expect(project.total_weeks).to be_within(0.01).of(5.14) }
  end

  describe '#past_weeks' do
    context 'with running project' do
      let(:project) { Fabricate :project, status: :executing, start_date: Time.zone.today, end_date: 4.weeks.from_now, qty_hours: 2000 }

      it { expect(project.past_weeks).to eq 1.1428571428571412 }
    end

    context 'with finished project' do
      let(:project) { Fabricate :project, status: :finished, start_date: Time.zone.today, end_date: 4.weeks.from_now, qty_hours: 2000 }

      it { expect(project.past_weeks).to be_within(0.01).of(5.14) }
    end
  end

  describe '#average_demand_aging' do
    context 'with demands' do
      it 'returns the average aging' do
        travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) do
          team = Fabricate :team
          project = Fabricate :project, team: team, initial_scope: 20

          Fabricate :demand, project: project, team: team, created_date: 4.days.ago
          Fabricate :demand, project: project, team: team, created_date: 3.days.ago
          Fabricate :demand, project: project, team: team, created_date: 2.days.ago, commitment_date: 1.day.ago, end_date: 1.hour.ago
          Fabricate :demand, project: project, team: team, created_date: 2.days.ago, discarded_at: 1.day.ago

          expect(project.average_demand_aging).to eq 0.6527777777777778
        end
      end
    end

    context 'with no demands' do
      it 'returns zero' do
        project = Fabricate :project, initial_scope: 20

        expect(project.average_demand_aging).to eq 0
      end
    end
  end

  describe '#quality' do
    context 'with data' do
      it 'returns the features percentage' do
        team = Fabricate :team
        project = Fabricate :project, team: team

        Fabricate :demand, project: project, team: team, created_date: 4.days.ago, demand_type: :feature
        Fabricate :demand, project: project, team: team, created_date: 3.days.ago, demand_type: :feature
        Fabricate :demand, project: project, team: team, created_date: 2.days.ago, demand_type: :chore
        Fabricate :demand, project: project, team: team, created_date: 2.days.ago, demand_type: :bug
        Fabricate :demand, project: project, team: team, created_date: 2.days.ago, demand_type: :bug, discarded_at: 1.day.ago

        expect(project.quality).to eq 0.75
      end
    end

    context 'with no bugs' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }
      let!(:first_demand) { Fabricate(:demand, project: project, created_date: 1.day.ago, end_date: nil, demand_type: :feature) }
      let!(:second_demand) { Fabricate(:demand, project: project, created_date: 1.day.ago, end_date: nil, demand_type: :chore) }

      it { expect(project.quality).to eq 1 }
    end

    context 'with no demands' do
      let!(:project) { Fabricate :project, end_date: 4.weeks.from_now, initial_scope: 30 }

      it { expect(project.quality).to eq 0 }
    end
  end

  describe '#delivered_scope' do
    include_context 'demands with effort'
    it { expect(project.delivered_scope).to eq 3 }
  end

  describe '#remaining_work' do
    it 'returns the remaining item for the specified date' do
      team = Fabricate :team
      project = Fabricate :project, team: team, initial_scope: 20

      first_stage = Fabricate :stage, teams: [team], projects: [project], order: 0
      second_stage = Fabricate :stage, teams: [team], projects: [project], order: 1

      first_demand = Fabricate :demand, project: project, team: team, created_date: 3.weeks.ago, commitment_date: 8.days.ago, end_date: 1.week.ago, demand_type: :bug
      second_demand = Fabricate :demand, project: project, team: team, created_date: 3.weeks.ago, commitment_date: 9.days.ago, end_date: 1.week.ago
      third_demand = Fabricate :demand, project: project, team: team, created_date: 2.weeks.ago, commitment_date: 10.days.ago, end_date: 2.days.ago
      fourth_demand = Fabricate :demand, project: project, team: team, created_date: 2.weeks.ago, commitment_date: 10.days.ago, end_date: 1.day.ago
      Fabricate :demand, project: project, team: team, created_date: Time.zone.now, commitment_date: Time.zone.now, end_date: nil
      Fabricate :demand, project: project, team: team, created_date: 4.weeks.ago, commitment_date: nil, end_date: nil, discarded_at: 2.weeks.ago

      Fabricate :demand_transition, demand: first_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
      Fabricate :demand_transition, demand: second_demand, stage: first_stage, last_time_in: 3.days.ago, last_time_out: nil
      Fabricate :demand_transition, demand: first_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
      Fabricate :demand_transition, demand: third_demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: nil
      Fabricate :demand_transition, demand: fourth_demand, stage: second_stage, last_time_in: 1.day.ago, last_time_out: nil

      expect(project.remaining_work).to eq 19
      expect(project.remaining_work(2.weeks.ago)).to eq 18
    end
  end

  describe '#last_weekly_throughput' do
    let(:project) { Fabricate :project }

    context 'with project consolidations' do
      let!(:first_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_throughput: 10 }
      let!(:second_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, project_throughput: 5 }
      let!(:third_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, project_throughput: 1 }

      it { expect(project.last_weekly_throughput(10)).to eq [4, 5] }
    end

    context 'with no consolidations' do
      it { expect(project.last_weekly_throughput(10)).to eq [] }
    end
  end

  describe '#current_weekly_scope_ideal_burnup' do
    context 'with data' do
      it 'returns the ideal values to burn the scope' do
        travel_to Time.zone.local(2020, 12, 2, 10, 0, 0) do
          project = Fabricate :project, start_date: Date.new(2020, 8, 2), end_date: Date.new(2021, 1, 2), initial_scope: 30
          expect(project.current_weekly_scope_ideal_burnup).to eq [1.3043478260869565, 2.608695652173913, 3.9130434782608696, 5.217391304347826, 6.521739130434783, 7.826086956521739, 9.130434782608695, 10.434782608695652, 11.73913043478261, 13.043478260869566, 14.347826086956522, 15.652173913043478, 16.956521739130434, 18.26086956521739, 19.565217391304348, 20.869565217391305, 22.17391304347826, 23.47826086956522, 24.782608695652176, 26.086956521739133, 27.391304347826086, 28.695652173913043, 30.0]
        end
      end
    end

    context 'with no data' do
      it 'returns an array with zero values' do
        travel_to Time.zone.local(2020, 12, 2, 10, 0, 0) do
          project = Fabricate :project, start_date: Time.zone.local(2020, 8, 2, 10, 0, 0), end_date: Time.zone.local(2021, 1, 2, 10, 0, 0), initial_scope: 0
          expect(project.current_weekly_scope_ideal_burnup).to eq [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        end
      end
    end
  end

  describe '#weekly_project_scope_until_end' do
    let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 2.weeks.from_now, initial_scope: 10 }

    context 'with project consolidations' do
      let!(:first_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 4.weeks.ago, project_scope: 5, last_data_in_week: true }
      let!(:second_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 3.weeks.ago, project_scope: 13, last_data_in_week: true }
      let!(:third_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 2.weeks.ago, project_scope: 18 }

      it { expect(project.weekly_project_scope_until_end).to eq [5, 13, 18, 18, 18, 18, 18] }
    end

    context 'with no consolidations' do
      it { expect(project.weekly_project_scope_until_end).to eq [10] }
    end
  end

  describe '#weekly_project_scope_hours_until_end' do
    let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 2.weeks.from_now, qty_hours: 10 }

    context 'with project consolidations' do
      let!(:first_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 4.weeks.ago, project_scope_hours: 5, last_data_in_week: true }
      let!(:second_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 3.weeks.ago, project_scope_hours: 13, last_data_in_week: true }
      let!(:third_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 2.weeks.ago, project_scope_hours: 18 }

      it { expect(project.weekly_project_scope_hours_until_end).to eq [5, 13, 18, 18, 18, 18, 18] }
    end

    context 'with no consolidations' do
      it { expect(project.weekly_project_scope_hours_until_end).to eq [10] }
    end
  end

  context 'callbacks' do
    describe '#remove_outdated_consolidations' do
      context 'with project consolidations' do
        it 'removes the consolidations outside project range' do
          project = Fabricate :project, start_date: 4.weeks.ago, end_date: 2.weeks.from_now, qty_hours: 10
          Fabricate :project_consolidation, project: project, consolidation_date: 5.weeks.ago, project_scope_hours: 5, last_data_in_week: true
          Fabricate :project_consolidation, project: project, consolidation_date: 3.weeks.ago, project_scope_hours: 13, last_data_in_week: true
          Fabricate :project_consolidation, project: project, consolidation_date: 4.weeks.from_now, project_scope_hours: 18

          project.remove_outdated_consolidations
          expect(project.project_consolidations.reload.count).to eq 1
        end
      end

      context 'with no consolidations' do
        let(:project) { Fabricate :project }

        before { project.remove_outdated_consolidations }

        it { expect(project.project_consolidations.reload.count).to eq 0 }
      end
    end

    describe '#update_initiative' do
      context 'with initiative' do
        it 'updates the initiative with the new date information if the dates are sooner or later than the other projects date' do
          company = Fabricate :company
          initiative = Fabricate :initiative, company: company, start_date: 4.weeks.ago, end_date: 2.weeks.from_now
          project = Fabricate :project, company: company, start_date: 4.weeks.ago, end_date: 2.weeks.from_now, initiative: initiative
          other_project = Fabricate :project, company: company, start_date: 3.weeks.ago, end_date: 1.week.from_now, initiative: initiative

          other_project.update(start_date: 1.month.ago, end_date: 1.month.from_now)

          initiative_reloaded = initiative.reload
          expect(initiative_reloaded.start_date).to eq other_project.start_date
          expect(initiative_reloaded.end_date).to eq other_project.end_date

          other_project.update(start_date: 3.weeks.ago, end_date: 1.week.from_now)
          expect(initiative_reloaded.start_date).to eq project.start_date
          expect(initiative_reloaded.end_date).to eq project.end_date
        end
      end

      context 'without initiative' do
        let(:project) { Fabricate :project }

        before { project.remove_outdated_consolidations }

        it { expect(project.project_consolidations.reload.count).to eq 0 }
      end
    end
  end

  describe '#qty_selected_in_week' do
    it 'returns the amount selected in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :demand, project: project, created_date: 2.weeks.ago, commitment_date: 9.days.ago, end_date: nil
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: nil
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: nil
        Fabricate :demand, project: project, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil

        expect(project.qty_selected_in_week).to eq 1
        expect(project.qty_selected_in_week(1.week.ago)).to eq 2
      end
    end
  end

  describe '#in_wip' do
    it 'returns the amount selected in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :demand, project: project, created_date: 2.weeks.ago, commitment_date: 9.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, created_date: 2.weeks.ago, commitment_date: 9.days.ago, end_date: nil
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: nil
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: nil
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        Fabricate :demand, project: project, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil

        expect(project.in_wip.count).to eq 3
        expect(project.in_wip(1.week.ago).count).to eq 2
      end
    end
  end

  describe '#monte_carlo_p80' do
    it 'returns the monte carlo value in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.week.ago, montecarlo_80_percent: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, montecarlo_80_percent: 0.2

        expect(project.monte_carlo_p80).to eq 0.2
        expect(project.monte_carlo_p80(1.week.ago)).to eq 5.9
      end
    end
  end

  describe '#team_monte_carlo_p80' do
    it 'returns the monte carlo value in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.week.ago, team_based_montecarlo_80_percent: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_based_montecarlo_80_percent: 0.2

        expect(project.team_monte_carlo_p80).to eq 0.2
        expect(project.team_monte_carlo_p80(1.week.ago)).to eq 5.9
      end
    end
  end

  describe '#team_monte_carlo_weeks_max' do
    it 'returns the monte carlo value in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.week.ago, team_monte_carlo_weeks_max: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_monte_carlo_weeks_max: 0.2

        expect(project.team_monte_carlo_weeks_max).to eq 0.2
        expect(project.team_monte_carlo_weeks_max(1.week.ago)).to eq 5.9
      end
    end
  end

  describe '#team_monte_carlo_weeks_min' do
    it 'returns the monte carlo value in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.week.ago, team_monte_carlo_weeks_min: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_monte_carlo_weeks_min: 0.2

        expect(project.team_monte_carlo_weeks_min).to eq 0.2
        expect(project.team_monte_carlo_weeks_min(1.week.ago)).to eq 5.9
      end
    end
  end

  describe '#team_monte_carlo_weeks_std_dev' do
    it 'returns the monte carlo value in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.week.ago, team_monte_carlo_weeks_std_dev: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_monte_carlo_weeks_std_dev: 0.2

        expect(project.team_monte_carlo_weeks_std_dev).to eq 0.2
        expect(project.team_monte_carlo_weeks_std_dev(1.week.ago)).to eq 5.9
      end
    end
  end

  describe '#team_based_odds_to_deadline' do
    it 'returns the monte carlo value in the given week' do
      travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
        project = Fabricate :project

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.week.ago, team_based_odds_to_deadline: 5.9
        Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_based_odds_to_deadline: 0.2

        expect(project.team_based_odds_to_deadline).to eq 0.2
        expect(project.team_based_odds_to_deadline(1.week.ago)).to eq 5.9
      end
    end
  end

  describe '#average_speed' do
    context 'with demands' do
      it 'returns the amount selected in the given week' do
        travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
          project = Fabricate :project, start_date: 3.weeks.ago, end_date: 3.days.from_now

          Fabricate :demand, project: project, created_date: 2.weeks.ago, commitment_date: 9.days.ago, end_date: 1.day.ago
          Fabricate :demand, project: project, created_date: 2.weeks.ago, commitment_date: 9.days.ago, end_date: 3.days.ago
          Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 4.days.ago
          Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: nil
          Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
          Fabricate :demand, project: project, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil

          expect(project.average_speed).to eq 0.8
        end
      end
    end

    context 'without demands' do
      it 'returns the amount selected in the given week' do
        travel_to Time.zone.local(2021, 12, 13, 10, 0, 0) do
          project = Fabricate :project, start_date: 3.weeks.ago, end_date: 3.days.from_now

          expect(project.average_speed).to eq 0
        end
      end
    end
  end

  describe '#lead_time_position_percentage' do
    context 'with data' do
      it 'returns the demand position within the others demands in the project' do
        project = Fabricate :project

        Fabricate :demand, project: project, created_date: 5.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :demand, project: project, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        Fabricate :demand, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, project: project, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, discarded_at: Time.zone.now

        tested_demand = Fabricate :demand, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        first_place_demand = Fabricate :demand, project: project, created_date: 7.days.ago, commitment_date: 2.hours.ago, end_date: 1.hour.ago
        last_place_demand = Fabricate :demand, project: project, created_date: 9.days.ago, commitment_date: 8.days.ago, end_date: 1.hour.ago

        expect(project.lead_time_position_percentage(tested_demand)).to eq 0.5
        expect(project.lead_time_position_percentage(first_place_demand)).to eq 1
        expect(project.lead_time_position_percentage(last_place_demand)).to eq 0
      end
    end

    context 'without data' do
      it 'returns zero' do
        project = Fabricate :project

        tested_demand = Fabricate :demand, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago

        expect(project.lead_time_position_percentage(tested_demand)).to eq 0
      end
    end
  end

  describe '#lead_time_position_percentage_same_type' do
    context 'with data' do
      it 'returns the demand position within the others demands in the project' do
        project = Fabricate :project

        Fabricate :demand, project: project, demand_type: :feature, created_date: 5.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :demand, project: project, demand_type: :feature, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, demand_type: :feature, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, demand_type: :feature, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        Fabricate :demand, demand_type: :feature, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, project: project, demand_type: :feature, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, discarded_at: Time.zone.now
        Fabricate :demand, project: project, demand_type: :bug, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        tested_demand = Fabricate :demand, demand_type: :feature, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        first_place_demand = Fabricate :demand, demand_type: :feature, project: project, created_date: 7.days.ago, commitment_date: 2.hours.ago, end_date: 1.hour.ago
        last_place_demand = Fabricate :demand, demand_type: :feature, project: project, created_date: 9.days.ago, commitment_date: 8.days.ago, end_date: 1.hour.ago

        expect(project.lead_time_position_percentage_same_type(tested_demand)).to eq 0.5
        expect(project.lead_time_position_percentage_same_type(first_place_demand)).to eq 1
        expect(project.lead_time_position_percentage_same_type(last_place_demand)).to eq 0
      end
    end

    context 'without data' do
      it 'returns zero' do
        project = Fabricate :project

        tested_demand = Fabricate :demand, demand_type: :feature, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago

        expect(project.lead_time_position_percentage_same_type(tested_demand)).to eq 0
      end
    end
  end

  describe '#lead_time_position_percentage_same_cos' do
    context 'with data' do
      it 'returns the demand position within the others demands in the project' do
        project = Fabricate :project

        Fabricate :demand, project: project, class_of_service: :standard, created_date: 5.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        Fabricate :demand, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, discarded_at: Time.zone.now
        Fabricate :demand, project: project, class_of_service: :fixed_date, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        tested_demand = Fabricate :demand, project: project, demand_type: :feature, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        first_place_demand = Fabricate :demand, project: project, demand_type: :feature, created_date: 7.days.ago, commitment_date: 2.hours.ago, end_date: 1.hour.ago
        last_place_demand = Fabricate :demand, project: project, demand_type: :feature, created_date: 9.days.ago, commitment_date: 8.days.ago, end_date: 1.hour.ago

        expect(project.lead_time_position_percentage_same_cos(tested_demand)).to eq 0.5
        expect(project.lead_time_position_percentage_same_cos(first_place_demand)).to eq 1
        expect(project.lead_time_position_percentage_same_cos(last_place_demand)).to eq 0
      end
    end

    context 'without data' do
      it 'returns zero' do
        project = Fabricate :project

        tested_demand = Fabricate :demand, demand_type: :feature, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago

        expect(project.lead_time_position_percentage_same_cos(tested_demand)).to eq 0
      end
    end
  end
end
