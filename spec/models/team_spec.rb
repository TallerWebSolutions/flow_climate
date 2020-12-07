# frozen_string_literal: true

RSpec.describe Team, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:team_members).through(:memberships) }
    it { is_expected.to have_and_belong_to_many(:stages) }
    it { is_expected.to have_many(:slack_configurations).dependent(:destroy) }
    it { is_expected.to have_many(:team_resource_allocations).dependent(:destroy) }
    it { is_expected.to have_many(:team_resources).through(:team_resource_allocations) }
    it { is_expected.to have_many(:demand_blocks).through(:demands) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
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
  end

  describe '#active_monthly_cost_for_billable_types' do
    include_context 'memberships for team'

    it { expect(team.active_monthly_cost_for_billable_types(%i[outsourcing consulting])).to eq 300.0 }
  end

  describe '#active_monthly_available_hours_for_billable_types' do
    include_context 'memberships for team'

    it { expect(team.active_monthly_available_hours_for_billable_types(%i[outsourcing consulting])).to eq 340 }
  end

  RSpec.shared_context 'consolidations data for team', shared_context: :metadata do
    let(:company) { Fabricate :company }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let(:product) { Fabricate :product, name: 'zzz' }
    let(:other_product) { Fabricate :product, name: 'zzz' }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000, value: 100_000, hour_value: 50 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, value: 20_000, hour_value: 100 }
    let(:other_customer_project) { Fabricate :project, team: other_team, end_date: 4.weeks.from_now, value: 45_000, hour_value: 20 }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug, effort_downstream: 20, effort_upstream: 30 }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40, effort_upstream: 35 }
    let!(:third_demand) { Fabricate :demand, team: team, project: project, created_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10, effort_upstream: 78 }
  end

  describe '#last_week_scope' do
    include_context 'consolidations data for team'
    it { expect(team.last_week_scope).to eq 33 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations data for team'
    it { expect(team.avg_hours_per_demand).to eq team.projects.sum(&:avg_hours_per_demand) / team.projects_count.to_f }
  end

  describe '#total_value' do
    include_context 'consolidations data for team'
    it { expect(team.total_value).to eq team.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'consolidations data for team'
    it { expect(team.remaining_money(4.weeks.from_now).to_f).to eq 89_350.0 }
  end

  describe '#percentage_remaining_money' do
    context 'having data' do
      include_context 'consolidations data for team'
      it { expect(team.percentage_remaining_money(4.weeks.from_now).to_f).to be_within(0.01).of 89.35 }
    end

    context 'having no data' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      it { expect(team.percentage_remaining_money(4.weeks.from_now).to_f).to eq 0 }
    end
  end

  describe '#remaining_backlog' do
    include_context 'consolidations data for team'
    it { expect(team.remaining_backlog).to eq 30 }
  end

  describe '#percentage_remaining_scope' do
    context 'having data' do
      include_context 'consolidations data for team'
      it { expect(team.percentage_remaining_scope).to eq 90.9090909090909 }
    end

    context 'having no data' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      it { expect(team.percentage_remaining_scope).to eq 0 }
    end
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations data for team'
    it { expect(team.total_flow_pressure).to be_within(0.2).of(team.projects.sum(&:flow_pressure)) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations data for team'
    it { expect(team.delivered_scope).to eq 3 }
  end

  describe '#consumed_hours_in_month' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    after { travel_back }

    let(:team) { Fabricate :team }

    context 'having data' do
      include_context 'consolidations data for team'
      it { expect(team.consumed_hours_in_month(Date.new(2018, 4, 5))).to eq 88 }
    end

    context 'having no data' do
      it { expect(team.consumed_hours_in_month(Date.new(2018, 4, 5))).to eq 0 }
    end
  end

  describe '#lead_time' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    after { travel_back }

    let(:team) { Fabricate :team }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:first_demand) { Fabricate :demand, team: team, project: project, commitment_date: 2.weeks.ago, end_date: 1.week.ago, demand_type: :bug, effort_downstream: 20, effort_upstream: 30 }
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
    let(:team) { Fabricate :team }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:first_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 20, effort_upstream: 30 }
      let!(:second_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, created_date: 2.weeks.ago, end_date: 1.week.ago, effort_downstream: 40, effort_upstream: 35 }
      let!(:third_demand) { Fabricate :demand, team: team, project: other_project, demand_type: :bug, created_date: 1.week.ago, end_date: 2.days.ago, effort_downstream: 10, effort_upstream: 78 }

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

    let!(:first_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 20, total_touch_time: 30 }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 40, total_touch_time: 35 }
    let!(:third_demand) { Fabricate :demand, team: team, project: other_project, demand_type: :bug, created_date: 1.week.ago, end_date: 2.days.ago, total_queue_time: 10, total_touch_time: 78 }

    it { expect(team.average_queue_time).to eq 23.333333333333332 }
    it { expect(other_team.average_queue_time).to eq 0 }
  end

  describe '#average_touch_time' do
    let(:company) { Fabricate :company }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 20, total_touch_time: 30 }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, created_date: 2.weeks.ago, end_date: 1.week.ago, total_queue_time: 40, total_touch_time: 35 }
    let!(:third_demand) { Fabricate :demand, team: team, project: other_project, demand_type: :bug, created_date: 1.week.ago, end_date: 2.days.ago, total_queue_time: 10, total_touch_time: 78 }

    it { expect(team.average_touch_time).to eq 47.666666666666664 }
    it { expect(other_team.average_touch_time).to eq 0 }
  end

  describe '#larger_lead_times' do
    let(:company) { Fabricate :company }

    let(:project) { Fabricate :project, team: team, end_date: 4.weeks.from_now, qty_hours: 2000 }
    let(:other_project) { Fabricate :project, team: team, end_date: 4.weeks.from_now }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, created_date: 3.weeks.ago, commitment_date: 17.days.ago, end_date: 2.weeks.ago }
    let!(:second_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, created_date: 2.weeks.ago, commitment_date: 18.days.ago, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand, team: team, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, team: other_team, project: other_project, demand_type: :bug, created_date: 1.week.ago, commitment_date: 4.days.ago, end_date: 2.days.ago }

    it { expect(team.larger_lead_times(0, 3)).to eq [second_demand, first_demand, third_demand] }
    it { expect(team.larger_lead_times(1, 2)).to eq [third_demand] }
  end

  describe '#percentage_idle_members' do
    let(:company) { Fabricate :company }

    let(:team) { Fabricate :team, company: company }

    let!(:first_team_member) { Fabricate :team_member, company: company }
    let!(:second_team_member) { Fabricate :team_member, company: company }
    let!(:third_team_member) { Fabricate :team_member, company: company }
    let!(:fourth_team_member) { Fabricate :team_member, company: company }
    let!(:fifth_team_member) { Fabricate :team_member, company: company }
    let!(:sixth_team_member) { Fabricate :team_member, company: company }

    let!(:first_membership) { Fabricate :membership, team_member: first_team_member, team: team, end_date: nil }
    let!(:second_membership) { Fabricate :membership, team_member: second_team_member, team: team, end_date: nil }
    let!(:third_membership) { Fabricate :membership, team_member: third_team_member, team: team, end_date: nil }
    let!(:fourth_membership) { Fabricate :membership, team_member: fourth_team_member, team: team, end_date: nil }
    let!(:fifth_membership) { Fabricate :membership, team_member: fifth_team_member, team: team, end_date: nil }
    let!(:sixth_membership) { Fabricate :membership, team_member: sixth_team_member, team: team, end_date: Time.zone.today }

    let(:other_team) { Fabricate :team, company: company }

    let(:empty_team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, end_date: nil }
    let!(:second_demand) { Fabricate :demand, team: team, end_date: nil }
    let!(:third_demand) { Fabricate :demand, team: team, end_date: nil }
    let!(:fourth_demand) { Fabricate :demand, team: team, end_date: Time.zone.now }
    let!(:fifth_demand) { Fabricate :demand, team: other_team, end_date: nil }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, membership: first_membership, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: first_demand, membership: second_membership, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: fourth_demand, membership: fourth_membership, finish_time: nil }

    it { expect(team.percentage_idle_members).to eq 0.6 }
    it { expect(other_team.percentage_idle_members).to eq 0 }
    it { expect(empty_team.percentage_idle_members).to eq 0 }
  end
end
