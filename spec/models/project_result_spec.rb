# frozen_string_literal: true

RSpec.describe ProjectResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :project }
    it { is_expected.to have_many(:demands).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :team }
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :result_date }
      it { is_expected.to validate_presence_of :known_scope }
      it { is_expected.to validate_presence_of :qty_hours_downstream }
      it { is_expected.to validate_presence_of :qty_hours_upstream }
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
    let(:project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.months.from_now }

    describe '.for_week' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago }
      let!(:third_result) { Fabricate :project_result, project: project, result_date: 1.week.ago }
      it { expect(ProjectResult.for_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to match_array [first_result, second_result] }
    end
    describe '.until_week' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.weeks.ago }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.week.ago }
      let!(:third_result) { Fabricate :project_result, project: project, result_date: 3.weeks.ago }
      let!(:fourth_result) { Fabricate :project_result, project: project, result_date: Time.zone.today }
      it { expect(ProjectResult.until_week(1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [first_result, second_result, third_result] }
    end
    describe '.until_month' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago }
      let!(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago }
      let!(:third_result) { Fabricate :project_result, project: project, result_date: 3.months.ago }
      let!(:fourth_result) { Fabricate :project_result, project: project, result_date: Time.zone.today }
      it { expect(ProjectResult.until_month(1.month.ago.to_date.month, 1.month.ago.to_date.year)).to match_array [first_result, second_result, third_result] }
    end

    describe '.in_month' do
      let(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago }
      let(:second_result) { Fabricate :project_result, project: project, result_date: 1.month.ago }
      let(:third_result) { Fabricate :project_result, project: project, result_date: 1.month.ago }
      let(:fourth_result) { Fabricate :project_result, project: project, result_date: 3.months.ago }
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

  describe '#total_hours' do
    let(:result) { Fabricate :project_result, qty_hours_upstream: 100, qty_hours_downstream: 50 }
    it { expect(result.total_hours).to eq 150 }
  end

  context 'demand dealers' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer, start_date: 2.days.ago, end_date: 3.days.from_now, initial_scope: 2 }

    let!(:result) { Fabricate :project_result, project: project, result_date: Date.new(2018, 4, 3), known_scope: 2032, cost_in_month: 30_000, throughput_upstream: 0, throughput_downstream: 0, flow_pressure: 2 }

    let!(:after_result_demand) { Fabricate :demand, project: project, created_date: Date.new(2018, 4, 5), end_date: Date.new(2018, 4, 6), effort_upstream: 50, effort_downstream: 12, downstream: true, leadtime: 20_000 }

    let!(:first_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 2), end_date: Date.new(2018, 4, 3), effort_upstream: 50, effort_downstream: 12, downstream: true, leadtime: 100 }
    let!(:second_demand) { Fabricate :demand, project: project, created_date: Date.new(2018, 4, 3), end_date: Date.new(2018, 4, 3), demand_type: :bug, effort_upstream: 100, effort_downstream: 20, downstream: true, leadtime: 40 }
    let!(:third_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 2), demand_type: :feature, effort_upstream: 70, effort_downstream: 10, downstream: false }
    let!(:fourth_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 2), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: false }

    let!(:fifth_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 3), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: true, discarded_at: Date.new(2018, 4, 3) }
    let!(:sixth_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 3), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: false, discarded_at: Date.new(2018, 4, 3) }

    let!(:seventh_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 3), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: true, discarded_at: Date.new(2018, 4, 2) }
    let!(:eigth_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 3), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: false, discarded_at: Date.new(2018, 4, 2) }

    let!(:nineth_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 3), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: true, discarded_at: Date.new(2018, 4, 4) }
    let!(:tenth_demand) { Fabricate :demand, project_result: result, project: project, created_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 3), demand_type: :feature, effort_upstream: 5, effort_downstream: 10, downstream: false, discarded_at: Date.new(2018, 4, 4) }

    describe '#add_demand!' do
      context 'when it does not have the demand yet' do
        it 'adds the demand and compute the flow metrics in the result' do
          expect(ProjectResult).to receive(:reset_counters).once
          result.add_demand!(second_demand)
          expect(ProjectResult.count).to eq 1
          result_updated = result.reload
          expect(result_updated.demands).to match_array [first_demand, second_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand]
          expect(result_updated.known_scope).to eq 8
          expect(result_updated.throughput_upstream).to eq 3
          expect(result_updated.throughput_downstream).to eq 3
          expect(result_updated.qty_hours_upstream.to_f).to eq 225.0
          expect(result_updated.qty_hours_downstream.to_f).to eq 52.0
          expect(result_updated.qty_hours_bug).to eq 20
          expect(result_updated.qty_bugs_closed).to eq 1
          expect(result_updated.qty_bugs_opened).to eq 1
          expect(result_updated.flow_pressure.to_f).to eq 1.33333333333333
          expect(result_updated.average_demand_cost.to_f).to eq 166.66666666666666
          expect(result_updated.leadtime_60_confidence.to_f).to eq 76.0
          expect(result_updated.leadtime_80_confidence.to_f).to eq 88.0
          expect(result_updated.leadtime_95_confidence.to_f).to eq 97.0
        end
      end
      context 'when it does already have the demand' do
        before { result.add_demand!(first_demand) }
        it { expect(result.reload.demands).to match_array [first_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand] }
      end
    end

    describe '#remove_demand!' do
      context 'when it has the demand' do
        it 'removes the demand and compute the flow metrics in t he result' do
          expect(ProjectResult).to receive(:reset_counters).once
          result.remove_demand!(second_demand)

          expect(ProjectResult.count).to eq 1
          expect(result.reload.demands).to match_array [first_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand]
          expect(result.reload.known_scope).to eq 8
          expect(result.reload.throughput_upstream).to eq 3
          expect(result.reload.throughput_downstream).to eq 2
          expect(result.reload.qty_hours_upstream.to_f).to eq 125.0
          expect(result.reload.qty_hours_downstream.to_f).to eq 32.0
          expect(result.reload.qty_hours_bug).to eq 0
          expect(result.reload.qty_bugs_closed).to eq 0
          expect(result.reload.qty_bugs_opened).to eq 0
          expect(result.reload.flow_pressure.to_f).to eq 1.33333333333333
          expect(result.reload.average_demand_cost.to_f).to eq 200.0
        end
      end
      context 'when it does not have the demand' do
        before { result.remove_demand!(second_demand) }
        it { expect(result.reload.demands).to match_array [first_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand] }
      end
    end
  end

  pending '#compute_flow_metrics!'
end
