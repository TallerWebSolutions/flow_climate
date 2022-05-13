# frozen_string_literal: true

RSpec.describe TeamMembersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user, first_name: 'zzz' }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #index' do
      it 'renders the SPA template' do
        get :index, params: { company_id: company }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #edit' do
      it 'renders the SPA template' do
        get :edit, params: { company_id: company, id: 'foo' }

        expect(response).to render_template 'spa-build/index'
      end
    end
  end
end
