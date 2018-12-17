# frozen_string_literal: true

RSpec.describe UserPlan, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:plan_billing_period).with(monthly: 0, yearly: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :plan }
    it { is_expected.to have_many(:demand_data_processments).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :plan }
    it { is_expected.to validate_presence_of :plan_billing_period }
    it { is_expected.to validate_presence_of :start_at }
    it { is_expected.to validate_presence_of :finish_at }
    it { is_expected.to validate_presence_of :plan_value }
    it 'uniqueness of user and plan and activation' do
      user = Fabricate :user
      plan = Fabricate :plan


      Fabricate(:user_plan, user: user, plan: plan, active: true, finish_at: 2.weeks.from_now)

      expect(Fabricate.build(:user_plan, user: user, plan: plan, active: true)).not_to be_valid
      expect(Fabricate.build(:user_plan, user: user, plan: plan, active: false)).not_to be_valid
      expect(Fabricate.build(:user_plan, user: user, active: true)).to be_valid
      expect(Fabricate.build(:user_plan, plan: plan, active: true)).to be_valid

      other_user = Fabricate :user
      other_plan = Fabricate :plan
      Fabricate(:user_plan, user: other_user, plan: other_plan, active: true, finish_at: 2.weeks.ago)
      expect(Fabricate.build(:user_plan, user: other_user, plan: other_plan, active: true)).to be_valid
    end
  end

  context 'scopes' do
    describe '.valid_plans' do
      context 'having plans' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let(:user) { Fabricate :user }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }
        let!(:inactive_user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false }
        let!(:finished_user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false, finish_at: 1.week.ago }

        it { expect(user.user_plans.valid_plans).to eq [user_plan] }
      end
    end
    describe '.inactive_in_period' do
      context 'having inactive in period user plans' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let(:user) { Fabricate :user }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false, finish_at: 2.weeks.from_now }
        let!(:other_user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, finish_at: 2.weeks.from_now }
        let!(:finished_user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false, finish_at: 1.week.ago }

        it { expect(user.user_plans.inactive_in_period(1.week.from_now)).to eq [user_plan] }
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:lite?).to(:plan) }
  end

  describe '#description' do
    let(:plan) { Fabricate :plan, plan_type: :lite, plan_period: :monthly }
    let!(:user_plan) { Fabricate :user_plan, plan: plan }
    it { expect(user_plan.description).to eq "#{plan.plan_type.capitalize} #{user_plan.plan_billing_period.capitalize}" }
  end
end
