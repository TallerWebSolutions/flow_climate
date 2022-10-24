# frozen_string_literal: true

RSpec.describe PlansController do
  context 'unauthenticated' do
    describe 'GET #no_plan' do
      before { get :no_plan }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #plan_choose' do
      before { post :plan_choose }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let!(:admin_user) { Fabricate :user, admin: true }
    let(:user) { Fabricate :user }

    before { sign_in user }

    describe 'GET #no_plan' do
      context 'no no_plan' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let!(:user_plan) { Fabricate :user_plan, active: true }

        before { get :no_plan }

        it { expect(response).to render_template :no_plan }
      end
    end

    describe 'POST #plan_choose' do
      let!(:plan) { Fabricate :plan }

      context 'having no inactive plans' do
        it 'creates the plan to the user and redirects to the root path' do
          expect(UserNotifierMailer).to receive(:plan_requested).once.and_call_original
          post :plan_choose, params: { plan_id: plan.id, period: :monthly, plan_value: 10 }
          expect(UserPlan.last).not_to be_nil
          expect(UserPlan.last.plan).to eq plan
          expect(UserPlan.last.user).to eq user
          expect(UserPlan.last.plan_value).to eq 10
          expect(UserPlan.last.plan_billing_period).to eq 'monthly'
          expect(UserPlan.last.finish_at).to be_within(1.day).of(30.days.from_now)

          expect(response).to redirect_to root_path
        end
      end

      context 'having inactive plans' do
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: false, finish_at: 1.day.from_now }

        before { post :plan_choose, params: { plan_id: plan.id, period: :monthly } }

        it 'creates the plan to the user and redirects to the root path' do
          expect(UserPlan.count).to eq 1

          expect(response).to redirect_to user_path(user)
        end
      end
    end
  end
end
