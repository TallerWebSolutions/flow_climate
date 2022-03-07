# frozen_string_literal: true

RSpec.describe AuthenticatedController, type: :controller do
  describe '#authenticate_user!' do
    controller do
      def some_action
        render plain: 'success'
      end
    end

    context 'unauthenticated' do
      it 'redirects to new session path' do
        routes.draw { get 'some_action' => 'authenticated#some_action' }
        get :some_action
        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authenticated' do
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
    controller do
      before_action :user_gold_check
      def some_action
        render plain: 'success'
      end
    end

    before { routes.draw { get 'some_action' => 'authenticated#some_action' } }

    context 'with a gold plan' do
      let(:plan) { Fabricate :plan, plan_type: :gold }
      let(:user) { Fabricate :user, first_name: 'zzz' }
      let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

      before { sign_in user }

      it 'validates the plan and renders the correct template' do
        get :some_action
        expect(controller.send(:user_gold_check)).to be true
        expect(response.status).to eq 200
        expect(response.body).to eq 'success'
      end
    end

    context 'with an admin' do
      let(:user) { Fabricate :user, first_name: 'zzz', admin: true }

      before { sign_in user }

      it 'has free and full access' do
        get :some_action
        expect(controller.send(:user_gold_check)).to be true
        expect(response.status).to eq 200
        expect(response.body).to eq 'success'
      end
    end

    context 'with a lite plan' do
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

    context 'with a trial plan' do
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

    context 'with no plan' do
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
