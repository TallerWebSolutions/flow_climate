# frozen_string_literal: true

RSpec.describe CompaniesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe '#show' do
      context 'passing a valid ID' do
        before { get :show, params: { id: 'foo' } }
        it { is_expected.to render_template :show }
      end
      context 'passing an invalid ID' do
      end
    end
  end
end
