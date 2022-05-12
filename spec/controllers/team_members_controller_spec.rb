# frozen_string_literal: true

RSpec.describe TeamMembersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    describe 'GET #index' do
      it 'renders the SPA template' do
        get :index, params: { company_id: company }

        expect(response).to render_template 'spa-build/index'
      end
    end
  end
end
