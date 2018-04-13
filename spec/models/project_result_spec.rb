# frozen_string_literal: true

RSpec.describe ProjectResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :project }
    it { is_expected.to have_many(:demands).dependent(:restrict_with_error) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :team }
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :result_date }
      it { is_expected.to validate_presence_of :known_scope }
      it { is_expected.to validate_presence_of :qty_hours_downstream }
      it { is_expected.to validate_presence_of :qty_hours_upstream }
      it { is_expected.to validate_presence_of :throughput_upstream }
      it { is_expected.to validate_presence_of :throughput_downstream }
      it { is_expected.to validate_presence_of :qty_bugs_opened }
      it { is_expected.to validate_presence_of :qty_bugs_closed }
      it { is_expected.to validate_presence_of :qty_hours_bug }
    end

    context 'complex ones' do
      describe '#result_date_greater_than_project_start_date' do
        let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 3.days.from_now, initial_scope: 2 }
        context 'when the result date is greater than to the end date' do
          let!(:result) { Fabricate.build :project_result, project: project, result_date: 4.days.from_now }
          it 'does not validate the model and add the error to the correct attribute' do
            expect(result.valid?).to be false
            expect(result.errors_on(:result_date)).to eq [I18n.t('project_result.validations.result_date_greater_than_project_start_date')]
          end
        end
        context 'when the result date is equal to the end date' do
          let!(:result) { Fabricate.build :project_result, project: project, result_date: 3.days.from_now }
          it { expect(result.valid?).to be true }
        end
        context 'when the result date is less than the end date' do
          let!(:result) { Fabricate.build :project_result, project: project, result_date: 1.day.from_now }
          it { expect(result.valid?).to be true }
        end
      end
    end
  end

  context 'scopes' do
    describe '.for_week' do
      let!(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let!(:second_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let!(:third_result) { Fabricate :project_result, result_date: 1.week.ago }
      it { expect(ProjectResult.for_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to match_array [first_result, second_result] }
    end
    describe '.until_week' do
      let!(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let!(:second_result) { Fabricate :project_result, result_date: 1.week.ago }
      let!(:third_result) { Fabricate :project_result, result_date: 3.weeks.ago }
      let!(:fourth_result) { Fabricate :project_result, result_date: Time.zone.today }
      it { expect(ProjectResult.until_week(1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [first_result, second_result, third_result] }
    end

    describe '.in_month' do
      let(:first_result) { Fabricate :project_result, result_date: 2.months.ago }
      let(:second_result) { Fabricate :project_result, result_date: 1.month.ago }
      let(:third_result) { Fabricate :project_result, result_date: 1.month.ago }
      let(:fourth_result) { Fabricate :project_result, result_date: 3.months.ago }
      it { expect(ProjectResult.in_month(1.month.ago)).to match_array [second_result, third_result] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team).with_prefix }
  end

  describe '#project_delivered_hours' do
    let(:result) { Fabricate :project_result }
    it { expect(result.project_delivered_hours).to eq result.qty_hours_upstream + result.qty_hours_downstream }
  end

  describe '#hours_per_demand_upstream' do
    context 'when the throughput is different of zero' do
      let(:result) { Fabricate :project_result }
      it { expect(result.hours_per_demand_upstream).to eq result.qty_hours_upstream.to_f / result.throughput_upstream.to_f }
    end
    context 'when the throughput is zero' do
      let(:result) { Fabricate :project_result, throughput_upstream: 0 }
      it { expect(result.hours_per_demand_upstream).to eq 0 }
    end
  end

  describe '#hours_per_demand_downstream' do
    context 'when the throughput is different of zero' do
      let(:result) { Fabricate :project_result }
      it { expect(result.hours_per_demand_downstream).to eq result.qty_hours_downstream.to_f / result.throughput_downstream.to_f }
    end
    context 'when the throughput is zero' do
      let(:result) { Fabricate :project_result, throughput_downstream: 0 }
      it { expect(result.hours_per_demand_downstream).to eq 0 }
    end
  end

  describe '#define_automatic_attributes!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'when the remaining days is different of zero and has no team yet' do
      let!(:project) { Fabricate :project, customer: customer, start_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 7), initial_scope: 10 }
      let!(:result) { Fabricate :project_result, project: project, result_date: Date.new(2018, 4, 3), known_scope: 20, throughput_upstream: 4, throughput_downstream: 2, cost_in_month: 432_123 }

      let!(:first_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 3), effort_upstream: 50, effort_downstream: 30 }
      let!(:second_demand) { Fabricate :demand, project: project, created_date: Date.new(2018, 4, 4), demand_type: :bug, effort_upstream: 100, effort_downstream: 120 }
      let!(:third_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 5), demand_type: :feature, effort_upstream: 70, effort_downstream: 73 }

      it 'defines the computed attributes' do
        result.define_automatic_attributes!
        expect(ProjectResult.last.known_scope).to eq 11
        expect(ProjectResult.last.remaining_days).to eq 5
        expect(ProjectResult.last.send(:current_gap)).to eq 5
        expect(ProjectResult.last.flow_pressure.to_f).to eq 1.0
        expect(ProjectResult.last.cost_in_month).to eq 0
        expect(ProjectResult.last.average_demand_cost.to_f).to eq 2400.6833333333334
        expect(ProjectResult.last.available_hours.to_f).to eq 0
      end
    end
    context 'when the project already has a team and a cost' do
      let(:team) { Fabricate :team }
      let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100, hours_per_month: 22, total_monthly_payment: 100 }
      let!(:other_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100, hours_per_month: 11, total_monthly_payment: 100 }
      let!(:project) { Fabricate :project, customer: customer, start_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 7), initial_scope: 10 }
      let!(:result) { Fabricate :project_result, project: project, team: team, result_date: Date.new(2018, 4, 3), known_scope: 20, throughput_upstream: 4, throughput_downstream: 6, cost_in_month: 100 }
      before { result.define_automatic_attributes! }
      it 'defines the automatic attributes' do
        expect(result.reload.cost_in_month.to_f).to eq 200.0
        expect(result.reload.average_demand_cost.to_f).to be_within(0.01).of(0.33)
        expect(result.reload.available_hours.to_f).to eq 1.1
      end
    end
    context 'when the project ends in the date of the result' do
      let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: Time.zone.yesterday, initial_scope: 5 }
      let(:result) { Fabricate :project_result, project: project, result_date: Time.zone.yesterday, known_scope: 50, throughput_upstream: 1, throughput_downstream: 2 }
      let!(:first_demand) { Fabricate :demand, project_result: result, project: project, created_date: Time.zone.today }
      let!(:second_demand) { Fabricate :demand, project: project, created_date: Time.zone.today, end_date: Time.zone.today }
      let!(:third_demand) { Fabricate :demand, project_result: result, project: project, created_date: Time.zone.today, end_date: Time.zone.today }

      it 'defines the automatic attributes' do
        result.define_automatic_attributes!
        expect(result.remaining_days).to eq 1
        expect(result.flow_pressure.to_f).to eq 2.0
      end
    end
    context 'when the current gap is zero' do
      let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: Time.zone.yesterday, initial_scope: 2 }
      let(:result) { Fabricate :project_result, project: project, result_date: Time.zone.yesterday, known_scope: 50, throughput_upstream: 50, throughput_downstream: 27 }
      it 'defines the automatic attributes' do
        result.define_automatic_attributes!
        expect(result.remaining_days).to eq 1
        expect(result.flow_pressure.to_f).to eq 0.0
      end
    end
  end

  describe '#total_hours' do
    let(:result) { Fabricate :project_result, qty_hours_upstream: 100, qty_hours_downstream: 50 }
    it { expect(result.total_hours).to eq 150 }
  end

  describe '#add_demand!' do
    let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 3.days.from_now, initial_scope: 2 }
    let!(:stage) { Fabricate :stage, projects: [project], end_point: true, compute_effort: true, stage_stream: :downstream }
    let!(:other_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, compute_effort: true, end_point: true }

    let!(:result) { Fabricate :project_result, project: project, result_date: Date.new(2018, 4, 3), known_scope: 2032, cost_in_month: 30_000, throughput_upstream: 0, throughput_downstream: 0, flow_pressure: 2 }

    let!(:first_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 2), end_date: Date.new(2018, 4, 3), effort_upstream: 50, effort_downstream: 12 }
    let!(:second_demand) { Fabricate :demand, project: project, created_date: Date.new(2018, 4, 3), end_date: Date.new(2018, 4, 3), demand_type: :bug, effort_upstream: 100, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 2), demand_type: :feature, effort_upstream: 70, effort_downstream: 10 }

    let!(:first_demand_transition) { Fabricate :demand_transition, stage: stage, demand: first_demand, last_time_in: Date.new(2018, 4, 2), last_time_out: Date.new(2018, 4, 3) }
    let!(:second_demand_transition) { Fabricate :demand_transition, stage: stage, demand: second_demand, last_time_in: Date.new(2018, 4, 3), last_time_out: Date.new(2018, 4, 4) }
    let!(:third_demand_transition) { Fabricate :demand_transition, stage: other_stage, demand: third_demand, last_time_in: Date.new(2018, 4, 4), last_time_out: Date.new(2018, 4, 6) }

    context 'when it does not have the demand yet' do
      it 'adds the demand and compute the flow metrics in the result' do
        expect(ProjectResult).to receive(:reset_counters).once
        result.add_demand!(second_demand)
        expect(ProjectResult.count).to eq 1
        expect(result.reload.demands).to match_array [first_demand, second_demand, third_demand]
        expect(result.reload.known_scope).to eq 5
        expect(result.reload.throughput_upstream).to eq 1
        expect(result.reload.throughput_downstream).to eq 2
        expect(result.reload.qty_hours_upstream).to eq 70
        expect(result.reload.qty_hours_downstream).to eq 32
        expect(result.reload.qty_hours_bug).to eq 20
        expect(result.reload.qty_bugs_closed).to eq 1
        expect(result.reload.qty_bugs_opened).to eq 1
        expect(result.reload.flow_pressure.to_f).to be_within(0.01).of(0.83)
        expect(result.reload.average_demand_cost.to_f).to eq 333.3333333333333
      end
    end
    context 'when it does already have the demand' do
      before { result.add_demand!(first_demand) }
      it { expect(result.reload.demands).to match_array [first_demand, third_demand] }
    end
  end

  describe '#remove_demand!' do
    let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 3.days.from_now, initial_scope: 2 }
    let(:stage) { Fabricate :stage, projects: [project], end_point: true, stage_stream: :downstream }
    let(:other_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, end_point: false }

    let!(:result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 2032, cost_in_month: 30_000, throughput_upstream: 0, throughput_downstream: 0, flow_pressure: 2 }

    let!(:first_demand) { Fabricate :demand, project_result: result, project: project, effort_upstream: 50, effort_downstream: 30 }
    let!(:second_demand) { Fabricate :demand, project: project, demand_type: :bug, effort_upstream: 100, effort_downstream: 120 }
    let!(:third_demand) { Fabricate :demand, project_result: result, project: project, demand_type: :feature, effort_upstream: 70, effort_downstream: 73 }

    let!(:first_demand_transition) { Fabricate :demand_transition, stage: stage, demand: first_demand, last_time_in: Time.zone.yesterday, last_time_out: Time.zone.today }
    let!(:second_demand_transition) { Fabricate :demand_transition, stage: stage, demand: second_demand, last_time_in: Time.zone.now, last_time_out: 2.hours.from_now }
    let!(:third_demand_transition) { Fabricate :demand_transition, stage: other_stage, demand: third_demand, last_time_in: Time.zone.tomorrow, last_time_out: 2.days.from_now }

    context 'when it has the demand' do
      it 'removes the demand and compute the flow metrics in t he result' do
        second_demand_transition.update(last_time_in: Time.zone.yesterday)
        expect(ProjectResult).to receive(:reset_counters).once
        result.remove_demand!(second_demand)

        expect(ProjectResult.count).to eq 1
        expect(result.reload.demands).to match_array [first_demand, third_demand]
        expect(result.reload.known_scope).to eq 5
        expect(result.reload.throughput_upstream).to eq 0
        expect(result.reload.throughput_downstream).to eq 1
        expect(result.reload.qty_hours_upstream).to eq 0
        expect(result.reload.qty_hours_downstream).to eq 30
        expect(result.reload.qty_hours_bug).to eq 0
        expect(result.reload.qty_bugs_closed).to eq 0
        expect(result.reload.qty_bugs_opened).to eq 0
        expect(result.reload.flow_pressure.to_f).to eq 1.25
        expect(result.reload.average_demand_cost.to_f).to eq 1000
      end
    end
    context 'when it does not have the demand' do
      before { result.remove_demand!(second_demand) }
      it { expect(result.reload.demands).to match_array [first_demand, third_demand] }
    end
  end

  pending '#compute_flow_metrics!'
end
