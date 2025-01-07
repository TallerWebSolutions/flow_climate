# frozen_string_literal: true

RSpec.describe ProductUsersController do
  context 'when unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo', product_id: 'foo' } }

      it { expect(response).to redirect_to new_session_path }
    end
  end

  context 'when authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company }

    before { login_as user }

    describe 'GET #index' do
      context 'passing a valid ID' do
        it 'renders the SPA template' do
          get :index, params: { company_id: company, product_id: product }

          expect(response).to render_template 'spa-build/index'
          expect(assigns(:company)).to eq company
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo', product_id: product } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
