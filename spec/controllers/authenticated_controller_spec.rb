# frozen_string_literal: true

RSpec.describe AuthenticatedController, type: :controller do
  describe '#authenticate_user!' do
    controller do
      def some_action
        render plain: 'success'
      end
    end
    context 'when unauthenticated' do
      it 'redirects to new session path' do
        routes.draw { get 'some_action' => 'authenticated#some_action' }
        get :some_action
        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when authenticated' do
      let(:user) { Fabricate :user }
      before { sign_in user }

      it 'calls the authneticate_user! method' do
        routes.draw { get 'some_action' => 'authenticated#some_action' }
        expect(controller).to receive(:authenticate_user!).once.and_call_original
        get :some_action
        expect(response.status).to eq 200
        expect(response.body).to eq 'success'
      end
    end
  end

  describe '#user_gold_check' do
    context 'when it is a gold plan' do
      let(:plan) { Fabricate :plan, plan_type: :gold }
      let(:user) { Fabricate :user, first_name: 'zzz' }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

      before { sign_in user }

      it { expect(controller.send(:user_gold_check)).to eq true }
    end

    context 'when user is an admin' do
      let(:user) { Fabricate :user, first_name: 'zzz', admin: true }
      before { sign_in user }
      it { expect(controller.send(:user_gold_check)).to eq true }
    end

    context 'when it is not a gold plan' do
      controller do
        before_action :user_gold_check
        def some_action
          render plain: 'success'
        end
      end

      context 'when it is a lite plan' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let(:user) { Fabricate :user, first_name: 'zzz' }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

        before { sign_in user }

        it 'redirects to the user path with an alert' do
          routes.draw { get 'some_action' => 'authenticated#some_action' }
          get :some_action
          expect(response).to redirect_to user_path(user)
          expect(flash[:alert]).to eq I18n.t('plans.validations.no_gold_plan')
        end
      end

      context 'when it is a trial plan' do
        let(:plan) { Fabricate :plan, plan_type: :trial }
        let(:user) { Fabricate :user, first_name: 'zzz' }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

        before { sign_in user }

        it 'redirects to the user path with an alert' do
          routes.draw { get 'some_action' => 'authenticated#some_action' }
          get :some_action
          expect(response).to redirect_to user_path(user)
          expect(flash[:alert]).to eq I18n.t('plans.validations.no_gold_plan')
        end
      end

      context 'when it has no plan' do
        let(:user) { Fabricate :user, first_name: 'zzz' }

        before { sign_in user }

        it 'redirects to the user path with an alert' do
          routes.draw { get 'some_action' => 'authenticated#some_action' }
          get :some_action
          expect(response).to redirect_to user_path(user)
          expect(flash[:alert]).to eq I18n.t('plans.validations.no_gold_plan')
        end
      end
    end
  end
end
