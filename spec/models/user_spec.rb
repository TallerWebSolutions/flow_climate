# frozen_string_literal: true

RSpec.describe User, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :companies }
    it { is_expected.to have_many(:user_project_roles).dependent(:destroy) }
    it { is_expected.to have_many(:projects).through(:user_project_roles) }
    it { is_expected.to have_many(:user_project_downloads).dependent(:destroy) }
    it { is_expected.to have_many(:user_plans).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :email }
  end

  context 'scopes' do
    describe '.to_notify_email' do
      context 'having data' do
        let(:first_user) { Fabricate :user, email_notifications: true }
        let(:second_user) { Fabricate :user, email_notifications: true }
        let(:third_user) { Fabricate :user, email_notifications: false }

        it { expect(User.to_notify_email).to match_array [first_user, second_user] }
      end
      context 'having no data' do
        it { expect(User.to_notify_email).to match_array [] }
      end
    end
  end

  describe '#lite?' do
    context 'having no plans' do
      let(:plan) { Fabricate :plan, plan_type: :lite }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false }

      it { expect(user.lite?).to be false }
    end
    context 'when it is lite' do
      let(:plan) { Fabricate :plan, plan_type: :lite }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }

      it { expect(user.lite?).to be true }
    end
  end

  describe '#standard?' do
    context 'having no plans' do
      let(:plan) { Fabricate :plan, plan_type: :standard }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false }

      it { expect(user.standard?).to be false }
    end
    context 'when it is standard' do
      let(:plan) { Fabricate :plan, plan_type: :standard }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }

      it { expect(user.standard?).to be true }
    end
  end

  describe '#gold?' do
    context 'having no plans' do
      let(:plan) { Fabricate :plan, plan_type: :gold }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false }

      it { expect(user.gold?).to be false }
    end
    context 'when it is gold' do
      let(:plan) { Fabricate :plan, plan_type: :gold }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }

      it { expect(user.gold?).to be true }
    end
  end

  describe '#no_plan?' do
    context 'having no plans' do
      let(:plan) { Fabricate :plan, plan_type: :lite }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false }

      it { expect(user.no_plan?).to be true }
    end
    context 'when it is lite' do
      let(:plan) { Fabricate :plan, plan_type: :lite }
      let(:user) { Fabricate :user }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }

      it { expect(user.no_plan?).to be false }
    end
  end
end
