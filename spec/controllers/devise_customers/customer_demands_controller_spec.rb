# frozen_string_literal: true

RSpec.describe DeviseCustomers::CustomerDemandsController do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_devise_customer_session_path }
    end
  end

  context 'authenticated' do
    let(:devise_customer) { Fabricate :devise_customer }

    before { sign_in devise_customer }

    describe 'GET #show' do
      it 'renders project spa page' do
        get :show, params: { id: 'foo' }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #demand_efforts' do
      it 'renders project spa page' do
        get :demand_efforts, params: { id: 'foo' }

        expect(response).to render_template 'spa-build/index'
      end
    end
  end
end
