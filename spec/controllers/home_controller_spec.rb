# frozen_string_literal: true

RSpec.describe HomeController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }
    describe 'GET #show' do
      context 'no plan' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let!(:user_plan) { Fabricate :user_plan, active: true }
        before { get :show }
        it { expect(response).to redirect_to no_plan_path }
      end
      context 'lite user' do
        let(:plan) { Fabricate :plan, plan_type: :lite }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }
        before { get :show }
        it { expect(response).to redirect_to request_project_information_path }
      end
      context 'standard user' do
        let(:plan) { Fabricate :plan, plan_type: :standard }
        let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }
        context 'and no companies' do
          before { get :show }
          it { expect(response).to redirect_to no_company_path }
        end
        context 'and having companies' do
          let!(:company) { Fabricate :company, users: [user] }
          before { get :show }
          it { expect(response).to redirect_to company_path(company) }
        end
        context 'gold user' do
          let(:plan) { Fabricate :plan, plan_type: :gold }
          let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true }
          context 'and no companies' do
            before { get :show }
            it { expect(response).to redirect_to no_company_path }
          end
          context 'and having companies' do
            let!(:company) { Fabricate :company, users: [user] }
            before { get :show }
            it { expect(response).to redirect_to company_path(company) }
          end
        end
      end
    end
  end
end
