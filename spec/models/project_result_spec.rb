# frozen_string_literal: true

RSpec.describe ProjectResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :project }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :team }
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :result_date }
      it { is_expected.to validate_presence_of :known_scope }
      it { is_expected.to validate_presence_of :qty_hours_downstream }
      it { is_expected.to validate_presence_of :qty_hours_upstream }
      it { is_expected.to validate_presence_of :throughput }
      it { is_expected.to validate_presence_of :qty_bugs_opened }
      it { is_expected.to validate_presence_of :qty_bugs_closed }
      it { is_expected.to validate_presence_of :qty_hours_bug }
    end

    context 'complex ones' do
      describe '#result_date_less_than_project_start_date' do
        let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 3.days.from_now }
        context 'when the result date is less than the start date' do
          let!(:result) { Fabricate.build :project_result, project: project, result_date: 3.days.ago }
          it 'does not validate the model and add the error to the correct attribute' do
            expect(result.valid?).to be false
            expect(result.errors_on(:result_date)).to eq [I18n.t('project_result.validations.result_date_less_than_project_start_date')]
          end
        end
        context 'when the result date is equal to the start date' do
          let!(:result) { Fabricate.build :project_result, project: project, result_date: 2.days.ago }
          it { expect(result.valid?).to be true }
        end
        context 'when the result date is greater than to the start date' do
          let!(:result) { Fabricate.build :project_result, project: project, result_date: 1.day.ago }
          it { expect(result.valid?).to be true }
        end
      end
      describe '#result_date_greater_than_project_start_date' do
        let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: 3.days.from_now }
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
      let(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:second_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:third_result) { Fabricate :project_result, result_date: 1.week.ago }
      it { expect(ProjectResult.for_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to match_array [first_result, second_result] }
    end
    describe '.until_week' do
      let(:first_result) { Fabricate :project_result, result_date: 2.weeks.ago }
      let(:second_result) { Fabricate :project_result, result_date: 1.week.ago }
      let(:third_result) { Fabricate :project_result, result_date: 3.weeks.ago }
      let(:fourth_result) { Fabricate :project_result, result_date: Time.zone.today }
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

  describe '#hours_per_demand' do
    context 'when the throughput is different of zero' do
      let(:result) { Fabricate :project_result }
      it { expect(result.hours_per_demand).to eq result.project_delivered_hours / result.throughput }
    end
    context 'when the throughput is zero' do
      let(:result) { Fabricate :project_result, throughput: 0 }
      it { expect(result.hours_per_demand).to eq 0 }
    end
  end

  describe '#define_automatic_attributes!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    context 'when the remaining days is different of zero and has no team yet' do
      let(:result) { Fabricate :project_result, project: project, known_scope: 20, throughput: 4 }
      before { result.define_automatic_attributes! }
      it { expect(result.reload.flow_pressure.to_f).to be_within(0.01).of(0.2711) }
      it { expect(result.reload.remaining_days).to eq 60 }
      it { expect(result.reload.cost_in_month).to eq 0 }
      it { expect(result.reload.average_demand_cost.to_f).to eq 0 }
      it { expect(result.reload.available_hours.to_f).to eq 0 }
    end
    context 'when the project already has a team and a cost' do
      let(:team) { Fabricate :team }
      let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100, hours_per_month: 22, total_monthly_payment: 100 }
      let!(:other_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100, hours_per_month: 11, total_monthly_payment: 100 }
      let!(:result) { Fabricate :project_result, project: project, team: team, known_scope: 20, throughput: 4 }
      before { result.define_automatic_attributes! }
      it 'defines the automatic attributes' do
        expect(result.reload.cost_in_month.to_f).to eq 200.0
        expect(result.reload.average_demand_cost.to_f).to eq 1.6666666666666667
        expect(result.reload.available_hours.to_f).to eq 1.1
      end
    end
    context 'when the remaining days is zero' do
      let(:project) { Fabricate :project, start_date: 2.days.ago, end_date: Time.zone.yesterday }
      let(:result) { Fabricate :project_result, project: project, result_date: Time.zone.yesterday, known_scope: 50, throughput: 10 }
      before { result.define_automatic_attributes! }
      it { expect(result.remaining_days).to eq 1 }
      it { expect(result.flow_pressure.to_f).to eq 40.0 }
    end
  end

  describe '#total_hours' do
    let(:result) { Fabricate :project_result, qty_hours_upstream: 100, qty_hours_downstream: 50 }
    it { expect(result.total_hours).to eq 150 }
  end

  pending '#add_demand!'
  pending '#remove_demand!'
end
