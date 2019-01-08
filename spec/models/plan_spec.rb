# frozen_string_literal: true

RSpec.describe Plan, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:plan_type).with_values(trial: 0, lite: 1, gold: 3) }
    it { is_expected.to define_enum_for(:plan_period).with_values(monthly: 0, yearly: 1) }
  end

  context 'associations' do
    it { is_expected.to have_many(:user_plans).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :plan_type }
    it { is_expected.to validate_presence_of :max_number_of_downloads }
    it { is_expected.to validate_presence_of :plan_value }
    it { is_expected.to validate_presence_of :extra_download_value }
    it { is_expected.to validate_presence_of :max_number_of_users }
    it { is_expected.to validate_presence_of :plan_period }
    it { is_expected.to validate_presence_of :max_days_in_history }
    it { is_expected.to validate_presence_of :plan_details }
  end

  describe '#yearly_value' do
    context 'yearly plan' do
      let(:plan) { Fabricate :plan, plan_period: :yearly, plan_value: 100 }

      it { expect(plan.yearly_value).to eq 100 }
    end

    context 'monthly plan' do
      let(:plan) { Fabricate :plan, plan_period: :monthly, plan_value: 100 }

      it { expect(plan.yearly_value).to eq((100 * 12) * 0.80) }
    end
  end

  describe '#monthly_value' do
    context 'yearly plan' do
      let(:plan) { Fabricate :plan, plan_period: :yearly, plan_value: 100 }

      it { expect(plan.monthly_value).to eq((100.0 / 12.0) * 1.2) }
    end

    context 'monthly plan' do
      let(:plan) { Fabricate :plan, plan_period: :monthly, plan_value: 100 }

      it { expect(plan.monthly_value).to eq 100 }
    end
  end

  describe '#free?' do
    context 'free plan' do
      let(:plan) { Fabricate :plan, plan_period: :yearly, plan_value: 0 }

      it { expect(plan.free?).to be true }
    end

    context 'paid plan' do
      let(:plan) { Fabricate :plan, plan_period: :monthly, plan_value: 100 }

      it { expect(plan.free?).to be false }
    end
  end
end
