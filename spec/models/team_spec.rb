# frozen_string_literal: true

RSpec.describe Team do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:demand_efforts).through(:demands) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:flow_events).dependent(:destroy) }
    it { is_expected.to have_many(:team_members).through(:memberships) }
    it { is_expected.to have_many(:stages_teams).dependent(:destroy) }
    it { is_expected.to have_many(:stages).through(:stages_teams) }
    it { is_expected.to have_many(:slack_configurations).dependent(:destroy) }
    it { is_expected.to have_many(:team_resource_allocations).dependent(:destroy) }
    it { is_expected.to have_many(:team_resources).through(:team_resource_allocations) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
    it { is_expected.to have_many(:team_consolidations).class_name('Consolidations::TeamConsolidation').dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :max_work_in_progress }

    context 'complex ones' do
      let(:company) { Fabricate :company }

      context 'uniqueness' do
        context 'same name in same customer' do
          let!(:team) { Fabricate :team, company: company, name: 'zzz' }
          let!(:other_team) { Fabricate.build :team, company: company, name: 'zzz' }

          it 'does not accept the model' do
            expect(other_team.valid?).to be false
            expect(other_team.errors[:name]).to eq ['Não deve repetir nome do time para a mesma empresa.']
          end
        end

        context 'different name in same customer' do
          let!(:team) { Fabricate :team, company: company, name: 'zzz' }
          let!(:other_team) { Fabricate.build :team, company: company, name: 'aaa' }

          it { expect(other_team.valid?).to be true }
        end

        context 'same name in different customer' do
          let!(:team) { Fabricate :team, company: company, name: 'zzz' }
          let!(:other_team) { Fabricate.build :team, name: 'zzz' }

          it { expect(other_team.valid?).to be true }
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:count).to(:projects).with_prefix }
  end

  RSpec.shared_context 'memberships for team', shared_context: :metadata do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let!(:team_member) { Fabricate :team_member, billable_type: :outsourcing, start_date: 2.days.ago, end_date: nil, monthly_payment: 100 }
    let!(:null_monthly_payment_member) { Fabricate :team_member, billable_type: :outsourcing, monthly_payment: nil, end_date: nil }
    let!(:consulting_member) { Fabricate :team_member, billable_type: :consulting, end_date: nil, monthly_payment: 200 }
    let!(:training_member) { Fabricate :team_member, billable_type: :training, end_date: nil, monthly_payment: 300 }
    let!(:not_billable_member) { Fabricate :team_member, billable: false, billable_type: nil, end_date: nil, monthly_payment: 150 }
    let!(:not_active_member) { Fabricate :team_member, billable_type: :outsourcing, end_date: 1.day.ago, monthly_payment: 123.12 }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 2.days.ago, end_date: nil }
    let!(:null_payment_membership) { Fabricate :membership, team: team, team_member: null_monthly_payment_member, hours_per_month: nil, start_date: 2.months.ago, end_date: nil }
    let!(:consulting_membership) { Fabricate :membership, team: team, team_member: consulting_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:training_membership) { Fabricate :membership, team: team, team_member: training_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:not_billable_member_membership) { Fabricate :membership, team: team, team_member: not_billable_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:not_active_member_membership) { Fabricate :membership, team: team, team_member: not_active_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:team_resource_allocation) { Fabricate :team_resource_allocation, team: team, monthly_payment: 100 }
  end

  describe '#monthly_investment' do
    include_context 'memberships for team'

    it { expect(team.monthly_investment).to be_within(0.1).of(956.4) }
  end

  describe '#available_hours_in_month_for' do
    include_context 'memberships for team'

    it { expect(team.available_hours_in_month_for).to eq 580 }
  end

  RSpec.shared_context 'consolidations data for team', shared_context: :metadata do
    let(:company) { Fabricate :company }

    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations data for team'

    it 'returns the average hours per demand' do
      travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) do
        first_demand = Fabricate :demand, team: team, created_date: 2.weeks.ago, end_date: 1.week.ago, work_item_type: bug_type, effort_downstream: 20
        second_demand = Fabricate :demand, team: team, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40
        third_demand = Fabricate :demand, team: team, created_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10

        Fabricate :demand_effort, demand: first_demand, start_time_to_computation: 4.days.ago, effort_value: 100
        Fabricate :demand_effort, demand: second_demand, start_time_to_computation: 15.days.ago, effort_value: 10
        Fabricate :demand_effort, demand: third_demand, start_time_to_computation: 15.days.ago, effort_value: 30

        expect(team.avg_hours_per_demand.to_f).to eq 46.666666666666664
      end
    end
  end

  describe '#consumed_hours_in_month' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    let(:team) { Fabricate :team }

    context 'with data' do
      include_context 'consolidations data for team'
      it 'returns the consumed hours in month' do
        travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) do
          first_demand = Fabricate :demand, team: team, created_date: 2.weeks.ago, end_date: 1.week.ago, work_item_type: bug_type, effort_downstream: 20
          second_demand = Fabricate :demand, team: team, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40
          third_demand = Fabricate :demand, team: team, created_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10

          Fabricate :demand_effort, demand: first_demand, start_time_to_computation: 4.days.ago, effort_value: 100
          Fabricate :demand_effort, demand: second_demand, start_time_to_computation: 15.days.ago, effort_value: 10
          Fabricate :demand_effort, demand: third_demand, start_time_to_computation: 15.days.ago, effort_value: 30

          expect(team.consumed_hours_in_month(Time.zone.today).to_f).to eq 100
        end
      end
    end

    context 'with no data' do
      it { expect(team.consumed_hours_in_month(Date.new(2018, 4, 5))).to eq 0 }
    end
  end

  describe '#lead_time' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    let(:team) { Fabricate :team }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:first_demand) { Fabricate :demand, team: team, project: project, commitment_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 20, effort_upstream: 30 }
      let!(:second_demand) { Fabricate :demand, team: team, project: project, commitment_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40, effort_upstream: 35 }
      let!(:third_demand) { Fabricate :demand, team: team, project: project, commitment_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10, effort_upstream: 78 }

      it { expect(team.lead_time(4.weeks.ago, Time.zone.now)).to be_within(0.1).of 604_800.0 }
      it { expect(team.lead_time(4.weeks.ago, Time.zone.now, 40)).to be_within(0.1).of 570_240.0 }
    end

    context 'with no data' do
      it { expect(team.lead_time(4.weeks.ago, Time.zone.now)).to eq 0 }
    end
  end

  describe '#failure_load' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team }

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:first_demand) { Fabricate :demand, team: team, project: project, work_item_type: feature_type, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 20, effort_upstream: 30 }
      let!(:second_demand) { Fabricate :demand, team: team, project: project, work_item_type: bug_type, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40, effort_upstream: 35 }
      let!(:third_demand) { Fabricate :demand, team: team, project: other_project, work_item_type: bug_type, created_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10, effort_upstream: 78 }

      it { expect(team.failure_load).to eq 66.66666666666666 }
    end

    context 'with no data' do
      it { expect(team.failure_load).to eq 0 }
    end
  end

  describe '#available_hours_at' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let!(:team_member) { Fabricate :team_member, billable_type: :outsourcing, start_date: 2.days.ago, end_date: nil }
    let!(:null_monthly_payment_member) { Fabricate :team_member, billable_type: :outsourcing, monthly_payment: nil, end_date: nil }
    let!(:consulting_member) { Fabricate :team_member, billable_type: :consulting, end_date: nil }
    let!(:training_member) { Fabricate :team_member, billable_type: :training, end_date: nil }
    let!(:not_billable_member) { Fabricate :team_member, billable: false, billable_type: nil, end_date: nil }
    let!(:not_active_member) { Fabricate :team_member, billable_type: :outsourcing, end_date: 1.day.ago }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 2.days.ago, end_date: nil }
    let!(:null_payment_membership) { Fabricate :membership, team: team, team_member: null_monthly_payment_member, hours_per_month: nil, start_date: 2.months.ago, end_date: nil }
    let!(:consulting_membership) { Fabricate :membership, team: team, team_member: consulting_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:training_membership) { Fabricate :membership, team: team, team_member: training_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:not_billable_member_membership) { Fabricate :membership, team: team, team_member: not_billable_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
    let!(:not_active_member_membership) { Fabricate :membership, team: team, team_member: not_active_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

    it { expect(team.available_hours_at(2.days.ago.to_date, 1.day.ago.to_date)).to eq 30.666666666666668 }
    it { expect(team.available_hours_at(20.days.ago.to_date, 15.days.ago.to_date)).to eq 72.0 }
    it { expect(team.available_hours_at(20.days.ago.to_date, Time.zone.today)).to eq 262.0 }
  end

  describe '#average_queue_time' do
    let(:company) { Fabricate :company }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 20, total_touch_time: 30 }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 40, total_touch_time: 35 }
    let!(:third_demand) { Fabricate :demand, team: team, project: other_project, created_date: 1.week.ago, end_date: 2.days.ago, total_queue_time: 10, total_touch_time: 78 }

    it { expect(team.average_queue_time).to eq 23.333333333333332 }
    it { expect(other_team.average_queue_time).to eq 0 }
  end

  describe '#average_touch_time' do
    let(:company) { Fabricate :company }
    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 20, total_touch_time: 30 }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 40, total_touch_time: 35 }
    let!(:third_demand) { Fabricate :demand, team: team, project: other_project, created_date: 1.week.ago, end_date: 2.days.ago, total_queue_time: 10, total_touch_time: 78 }

    it { expect(team.average_touch_time).to eq 47.666666666666664 }
    it { expect(other_team.average_touch_time).to eq 0 }
  end

  describe '#larger_lead_times' do
    let(:company) { Fabricate :company }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, team: team, project: other_project, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, team: other_team, project: other_project, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }

    it { expect(team.larger_lead_times(0, 3)).to eq [second_demand, first_demand, third_demand] }
    it { expect(team.larger_lead_times(1, 2)).to eq [third_demand] }
  end

  describe '#count_idle_by_role' do
    it 'returns the idle roles' do
      company = Fabricate :company
      team = Fabricate :team, company: company

      first_team_member = Fabricate :team_member, company: company
      second_team_member = Fabricate :team_member, company: company
      third_team_member = Fabricate :team_member, company: company
      fourth_team_member = Fabricate :team_member, company: company
      fifth_team_member = Fabricate :team_member, company: company
      sixth_team_member = Fabricate :team_member, company: company

      first_membership = Fabricate :membership, team_member: first_team_member, team: team, end_date: nil, member_role: :developer
      Fabricate :membership, team_member: second_team_member, team: team, end_date: nil, member_role: :manager
      Fabricate :membership, team_member: third_team_member, team: team, end_date: nil, member_role: :designer
      Fabricate :membership, team_member: fourth_team_member, team: team, end_date: nil, member_role: :manager
      Fabricate :membership, team_member: fifth_team_member, team: team, end_date: nil, member_role: :developer
      Fabricate :membership, team_member: sixth_team_member, team: team, end_date: Time.zone.today, member_role: :manager

      other_team = Fabricate :team, company: company
      empty_team = Fabricate :team, company: company

      first_demand = Fabricate :demand, team: team, end_date: nil
      Fabricate :demand, team: team, end_date: nil
      Fabricate :demand, team: team, end_date: nil
      Fabricate :demand, team: team, end_date: Time.zone.now
      Fabricate :demand, team: other_team, end_date: nil

      Fabricate :item_assignment, demand: first_demand, membership: first_membership, finish_time: nil

      expect(team.count_idle_by_role).to eq({ 'designer' => 1, 'developer' => 1, 'manager' => 3 })
      expect(other_team.count_idle_by_role).to eq({})
      expect(empty_team.count_idle_by_role).to eq({})
    end
  end

  describe '#percentage_idle_members' do
    it 'computes the value' do
      travel_to Time.zone.local(2018, 4, 6, 10) do
        company = Fabricate :company
        team = Fabricate :team, company: company

        first_team_member = Fabricate :team_member, company: company
        second_team_member = Fabricate :team_member, company: company
        third_team_member = Fabricate :team_member, company: company
        fourth_team_member = Fabricate :team_member, company: company
        fifth_team_member = Fabricate :team_member, company: company
        sixth_team_member = Fabricate :team_member, company: company

        first_membership = Fabricate :membership, team_member: first_team_member, team: team, end_date: nil
        second_membership = Fabricate :membership, team_member: second_team_member, team: team, end_date: nil
        third_membership = Fabricate :membership, team_member: fourth_team_member, team: team, end_date: nil
        Fabricate :membership, team_member: third_team_member, team: team, end_date: nil
        Fabricate :membership, team_member: fifth_team_member, team: team, end_date: nil
        Fabricate :membership, team_member: sixth_team_member, team: team, end_date: Time.zone.today

        other_team = Fabricate :team, company: company
        empty_team = Fabricate :team, company: company

        first_demand = Fabricate :demand, team: team, end_date: nil
        second_demand = Fabricate :demand, team: team, end_date: Time.zone.now
        Fabricate :demand, team: team, end_date: nil
        Fabricate :demand, team: team, end_date: nil
        Fabricate :demand, team: other_team, end_date: nil

        Fabricate :item_assignment, demand: first_demand, membership: first_membership, finish_time: nil
        Fabricate :item_assignment, demand: first_demand, membership: second_membership, finish_time: nil
        Fabricate :item_assignment, demand: second_demand, membership: third_membership, finish_time: nil

        expect(team.percentage_idle_members).to eq 0.6666666666666666
        expect(other_team.percentage_idle_members).to eq 0
        expect(empty_team.percentage_idle_members).to eq 0
      end
    end
  end

  describe '#initial_scope' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let(:no_projects_team) { Fabricate :team, company: company }

    let!(:first_roject) { Fabricate :project, company: company, team: team, status: :executing, initial_scope: 10, end_date: 4.weeks.from_now }
    let!(:second_project) { Fabricate :project, company: company, team: team, status: :waiting, initial_scope: 8, end_date: 2.weeks.from_now }
    let!(:third_project) { Fabricate :project, company: company, team: other_team, status: :waiting, initial_scope: 210, end_date: 30.weeks.from_now }
    let!(:fourth_project) { Fabricate :project, company: company, team: team, status: :finished, initial_scope: 410, end_date: 30.weeks.from_now }

    it { expect(team.initial_scope).to eq 18 }
    it { expect(other_team.initial_scope).to eq 210 }
    it { expect(no_projects_team.initial_scope).to eq 0 }
  end

  describe '#flow_pressure' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }
    let(:no_projects_team) { Fabricate :team, company: company }

    it 'computes the correct flow pressure' do
      travel_to Time.zone.local(2020, 11, 1, 10, 0, 0) do
        Fabricate :project, company: company, team: team, status: :executing, initial_scope: 10, start_date: Time.zone.local(2020, 11, 1, 10, 0, 0), end_date: Time.zone.local(2021, 1, 12, 10, 0, 0)
        Fabricate :project, company: company, team: team, status: :waiting, initial_scope: 15, start_date: Time.zone.local(2020, 10, 1, 10, 0, 0), end_date: Time.zone.local(2021, 2, 12, 10, 0, 0)
        Fabricate :project, company: company, team: other_team, status: :waiting, initial_scope: 20, start_date: Time.zone.local(2020, 9, 1, 10, 0, 0), end_date: Time.zone.local(2021, 1, 20, 10, 0, 0)
        Fabricate :project, company: company, team: team, status: :finished, initial_scope: 5, start_date: Time.zone.local(2020, 11, 1, 10, 0, 0), end_date: Time.zone.local(2021, 1, 1, 10, 0, 0)

        expect(team.flow_pressure).to be_within(0.5).of 0.2
        expect(other_team.flow_pressure).to be_within(0.3).of 0.2
        expect(no_projects_team.flow_pressure).to eq 0
      end
    end
  end

  describe '#active?' do
    let(:company) { Fabricate :company }

    it 'returns true when the customer has active projects' do
      active_team = Fabricate :team, company: company
      inactive_team = Fabricate :team, company: company
      no_projects_team = Fabricate :team, company: company

      Fabricate :project, company: company, team: active_team, status: :executing, initial_scope: 10, end_date: 4.weeks.from_now
      Fabricate :project, company: company, team: active_team, status: :waiting, initial_scope: 8, end_date: 2.weeks.from_now
      Fabricate :project, company: company, team: active_team, status: :finished, initial_scope: 410, end_date: 30.weeks.from_now
      Fabricate :project, company: company, team: active_team, status: :finished, initial_scope: 410, end_date: 30.weeks.from_now

      expect(active_team.active?).to be true
      expect(inactive_team.active?).to be false
      expect(no_projects_team.active?).to be false
    end
  end

  describe '#start_date' do
    let(:company) { Fabricate :company }

    it 'returns the start team date' do
      team = Fabricate :team, company: company
      other_team = Fabricate :team, company: company
      empty_team = Fabricate :team, company: company

      feature_type = Fabricate :work_item_type, company: company, name: 'Feature'
      bug_type = Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true

      Fabricate :demand, team: team, work_item_type: feature_type, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 30, effort_upstream: 10
      Fabricate :demand, team: team, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, team: team, work_item_type: bug_type, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: nil, effort_downstream: 2, effort_upstream: 18
      Fabricate :demand, team: team, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, team: team, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: nil, effort_downstream: 43, effort_upstream: 49
      Fabricate :demand, team: other_team, work_item_type: bug_type, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago, effort_downstream: 38, effort_upstream: 15

      expect(team.start_date).to eq 2.weeks.ago.to_date
      expect(team.end_date).to eq 2.days.ago.to_date
      expect(empty_team.start_date).to eq Time.zone.today
      expect(empty_team.end_date).to eq Time.zone.today
    end
  end

  describe '#lead_time_position_percentage' do
    context 'with data' do
      it 'returns the demand position within the others demands in the project' do
        team = Fabricate :team

        Fabricate :demand, team: team, created_date: 5.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :demand, team: team, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago
        Fabricate :demand, team: team, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 1.day.ago
        Fabricate :demand, team: team, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        Fabricate :demand, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, team: team, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, discarded_at: Time.zone.now

        tested_demand = Fabricate :demand, team: team, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        first_place_demand = Fabricate :demand, team: team, created_date: 7.days.ago, commitment_date: 2.hours.ago, end_date: 1.hour.ago
        last_place_demand = Fabricate :demand, team: team, created_date: 9.days.ago, commitment_date: 8.days.ago, end_date: 1.hour.ago

        expect(team.lead_time_position_percentage(tested_demand)).to eq 0.5
        expect(team.lead_time_position_percentage(first_place_demand)).to eq 1
        expect(team.lead_time_position_percentage(last_place_demand)).to eq 0
      end
    end

    context 'without data' do
      it 'returns zero' do
        team = Fabricate :team

        tested_demand = Fabricate :demand, team: team, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago

        expect(team.lead_time_position_percentage(tested_demand)).to eq 0
      end
    end
  end

  describe '#lead_time_position_percentage_same_type' do
    context 'with data' do
      it 'returns the demand position within the others demands in the project' do
        company = Fabricate :company
        project = Fabricate :project, company: company

        feature_type = Fabricate :work_item_type, company: company, name: 'Feature'
        bug_type = Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true

        Fabricate :demand, project: project, work_item_type: feature_type, created_date: 5.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :demand, project: project, work_item_type: feature_type, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, work_item_type: feature_type, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, work_item_type: feature_type, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        Fabricate :demand, work_item_type: feature_type, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, project: project, work_item_type: feature_type, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, discarded_at: Time.zone.now
        Fabricate :demand, project: project, work_item_type: bug_type, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        tested_demand = Fabricate :demand, work_item_type: feature_type, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        first_place_demand = Fabricate :demand, work_item_type: feature_type, project: project, created_date: 7.days.ago, commitment_date: 2.hours.ago, end_date: 1.hour.ago
        last_place_demand = Fabricate :demand, work_item_type: feature_type, project: project, created_date: 9.days.ago, commitment_date: 8.days.ago, end_date: 1.hour.ago

        expect(project.lead_time_position_percentage_same_type(tested_demand)).to eq 0.5
        expect(project.lead_time_position_percentage_same_type(first_place_demand)).to eq 1
        expect(project.lead_time_position_percentage_same_type(last_place_demand)).to eq 0
      end
    end

    context 'without data' do
      it 'returns zero' do
        project = Fabricate :project

        tested_demand = Fabricate :demand, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago

        expect(project.lead_time_position_percentage_same_type(tested_demand)).to eq 0
      end
    end
  end

  describe '#lead_time_position_percentage_same_cos' do
    context 'with data' do
      it 'returns the demand position within the others demands in the project' do
        company = Fabricate :company

        project = Fabricate :project, company: company

        feature_type = Fabricate :work_item_type, company: company, name: 'Feature'

        Fabricate :demand, project: project, class_of_service: :standard, created_date: 5.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 5.days.ago, end_date: 1.day.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        Fabricate :demand, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago
        Fabricate :demand, project: project, class_of_service: :standard, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, discarded_at: Time.zone.now
        Fabricate :demand, project: project, class_of_service: :fixed_date, created_date: 6.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago

        tested_demand = Fabricate :demand, project: project, work_item_type: feature_type, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago
        first_place_demand = Fabricate :demand, project: project, work_item_type: feature_type, created_date: 7.days.ago, commitment_date: 2.hours.ago, end_date: 1.hour.ago
        last_place_demand = Fabricate :demand, project: project, work_item_type: feature_type, created_date: 9.days.ago, commitment_date: 8.days.ago, end_date: 1.hour.ago

        expect(project.lead_time_position_percentage_same_cos(tested_demand)).to eq 0.5
        expect(project.lead_time_position_percentage_same_cos(first_place_demand)).to eq 1
        expect(project.lead_time_position_percentage_same_cos(last_place_demand)).to eq 0
      end
    end

    context 'without data' do
      it 'returns zero' do
        project = Fabricate :project

        tested_demand = Fabricate :demand, project: project, created_date: 7.days.ago, commitment_date: 4.days.ago, end_date: 2.days.ago

        expect(project.lead_time_position_percentage_same_cos(tested_demand)).to eq 0
      end
    end
  end

  describe '#size_at' do
    context 'with memberships' do
      it 'returns the count of active memberships' do
        travel_to Time.zone.local(2022, 6, 23, 10) do
          team = Fabricate :team
          Fabricate :membership, team: team, start_date: 3.days.ago, end_date: nil
          Fabricate :membership, team: team, start_date: Time.zone.today, end_date: 4.days.from_now
          Fabricate :membership, team: team, start_date: 4.days.ago, end_date: 3.days.ago
          Fabricate :membership, team: team, start_date: 2.days.ago, end_date: 1.day.from_now

          expect(team.size_at(Time.zone.yesterday)).to eq 2
          expect(team.size_at).to eq 3
        end
      end
    end

    context 'without memberships' do
      it 'returns zero' do
        team = Fabricate :team

        expect(team.size_at).to eq 0
      end
    end
  end

  describe '#size_using_available_hours' do
    context 'with memberships' do
      it 'returns the count of active memberships' do
        travel_to Time.zone.local(2022, 6, 23, 10) do
          team = Fabricate :team
          Fabricate :membership, team: team, start_date: 3.days.ago, end_date: nil, hours_per_month: 10
          Fabricate :membership, team: team, start_date: Time.zone.today, end_date: 4.days.from_now, hours_per_month: 20
          Fabricate :membership, team: team, start_date: 4.days.ago, end_date: 3.days.ago, hours_per_month: 30
          Fabricate :membership, team: team, start_date: 2.days.ago, end_date: 1.day.from_now, hours_per_month: 50

          expect(team.size_using_available_hours(Time.zone.yesterday)).to be_within(0.1).of(0.5)
          expect(team.size_using_available_hours).to be_within(0.1).of(0.6)
        end
      end
    end

    context 'without memberships' do
      it 'returns zero' do
        team = Fabricate :team

        expect(team.size_at).to eq 0
      end
    end
  end

  describe '#loss_at' do
    context 'with memberships' do
      it 'returns the loss for the date' do
        travel_to Time.zone.local(2022, 6, 23, 10) do
          team = Fabricate :team
          Fabricate :membership, team: team, start_date: 3.days.ago, end_date: nil, hours_per_month: 60
          Fabricate :membership, team: team, start_date: Time.zone.today, end_date: 4.days.from_now, hours_per_month: 120
          Fabricate :membership, team: team, start_date: 4.days.ago, end_date: 3.days.ago, hours_per_month: 40
          Fabricate :membership, team: team, start_date: 2.days.ago, end_date: 1.day.from_now, hours_per_month: 60

          demand = Fabricate :demand, team: team
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 4.days.ago, effort_value: 100
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 15.days.ago, effort_value: 10

          expect(team.loss_at(Time.zone.yesterday).to_f).to be_within(0.01).of(0.08)
          expect(team.loss_at.to_f).to be_within(0.01).of(0.54)
        end
      end
    end

    context 'without memberships' do
      it 'returns zero' do
        team = Fabricate :team

        expect(team.loss_at).to eq 0
      end
    end
  end

  describe '#percentage_concluded' do
    context 'when it has no demands' do
      it 'returns zero' do
        unit = Fabricate :portfolio_unit
        expect(unit.percentage_concluded).to be_zero
      end
    end

    context 'when it has demands' do
      context 'and none concluded' do
        it 'returns zero' do
          team = Fabricate :team
          Fabricate :demand, team: team, end_date: nil
          expect(team.percentage_concluded).to be_zero
        end
      end

      context 'and some are concluded' do
        it 'returns the relation between the numbers' do
          team = Fabricate :team
          Fabricate :demand, team: team, end_date: nil
          Fabricate :demand, team: team, end_date: nil
          Fabricate :demand, team: team, end_date: nil
          Fabricate :demand, team: team, end_date: Time.zone.now
          Fabricate :demand, team: team, end_date: Time.zone.now

          expect(team.percentage_concluded).to eq 0.4
        end
      end
    end
  end

  describe '#expected_loss_at' do
    context 'for the beginning of month' do
      it 'returns the proportional loss to the date' do
        travel_to Time.zone.local(2022, 11, 8, 10) do
          team = Fabricate :team

          Fabricate :membership, team: team, hours_per_month: 100, start_date: 30.days.ago, end_date: nil
          Fabricate :membership, team: team, hours_per_month: 200, start_date: 30.days.ago, end_date: nil

          expect(team.expected_loss_at).to eq 0.7727272727272727
        end
      end
    end

    context 'for the end of month' do
      it 'returns the proportional loss to the date' do
        travel_to Time.zone.local(2022, 11, 30, 10) do
          team = Fabricate :team

          Fabricate :membership, team: team, hours_per_month: 100, start_date: 30.days.ago, end_date: nil
          Fabricate :membership, team: team, hours_per_month: 200, start_date: 30.days.ago, end_date: nil

          expect(team.expected_loss_at).to be_within(0.01).of 0.045
        end
      end
    end
  end

  describe '#average_consumed_hours_per_person_per_day' do
    it 'returns the average value' do
      travel_to Time.zone.local(2022, 11, 8, 10) do
        team = Fabricate :team

        Fabricate :membership, team: team, hours_per_month: 100, start_date: 30.days.ago, end_date: nil
        Fabricate :membership, team: team, hours_per_month: 200, start_date: 30.days.ago, end_date: nil

        demand = Fabricate :demand, team: team
        Fabricate :demand_effort, demand: demand, start_time_to_computation: 4.days.ago, effort_value: 100
        Fabricate :demand_effort, demand: demand, start_time_to_computation: 15.days.ago, effort_value: 10

        expect(team.average_consumed_hours_per_person_per_day).to eq 6.666666666666667
      end
    end
  end

  describe '#active_billable_count' do
    it 'returns the active billable members count' do
      travel_to Time.zone.local(2022, 11, 8, 10) do
        team = Fabricate :team

        Fabricate :membership, team: team, hours_per_month: 100, start_date: 30.days.ago, end_date: nil
        Fabricate :membership, team: team, hours_per_month: 200, start_date: 30.days.ago, end_date: nil
        Fabricate :membership, team: team, hours_per_month: 200, start_date: 30.days.ago, end_date: 1.day.ago

        expect(team.active_billable_count).to eq 2
      end
    end
  end

  describe '#expected_consumption' do
    context 'with memberships' do
      it 'returns the expetected value' do
        travel_to Time.zone.local(2022, 11, 8, 10) do
          team = Fabricate :team

          Fabricate :membership, team: team, hours_per_month: 100, start_date: 30.days.ago, end_date: nil
          Fabricate :membership, team: team, hours_per_month: 200, start_date: 30.days.ago, end_date: nil

          expect(team.expected_consumption).to eq 81.81818181818181
        end
      end
    end

    context 'without memberships' do
      it 'returns 0' do
        travel_to Time.zone.local(2022, 11, 8, 10) do
          team = Fabricate :team

          expect(team.expected_consumption).to eq 0
        end
      end
    end
  end
end
