# frozen_string_literal: true

RSpec.describe UserPlan, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:plan_billing_period).with(monthly: 0, annualy: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :plan }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :plan }
    it { is_expected.to validate_presence_of :plan_billing_period }
    it { is_expected.to validate_presence_of :start_at }
    it { is_expected.to validate_presence_of :finish_at }
  end

  context 'scopes' do
    describe '.valid_plans' do
      context 'having plans' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let(:user) { Fabricate :user }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }

        it { expect(user.user_plans.valid_plans).to eq [user_plan] }
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:lite?).to(:plan) }
  end
end
