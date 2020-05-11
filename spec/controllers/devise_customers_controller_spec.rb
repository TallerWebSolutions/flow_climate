# frozen_string_literal: true

RSpec.describe DeviseCustomersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #home' do
      before { get :home }

      it { expect(response).to redirect_to new_devise_customer_session_path }
    end
  end

  context 'authenticated' do
    let(:devise_customer) { Fabricate :devise_customer }

    before { sign_in devise_customer }

    describe 'GET #home' do
      context 'with a customer with no data' do
        let!(:customer) { Fabricate :customer, devise_customers: [devise_customer] }

        it 'renders the no data layout' do
          expect(CustomerDashboardData).to(receive(:new).once.and_call_original)
          expect(Highchart::DemandsChartsAdapter).to(receive(:new).once.and_call_original)
          get :home

          expect(response).to render_template 'devise_customers/home'
          expect(response).to render_template 'common/dashboards/_general_info'
        end
      end

      context 'with no customer' do
        before { get :home }

        it 'renders the no data layout' do
          expect(response).to render_template 'devise_customers/home'
          expect(response).to render_template 'layouts/_no_data'
        end
      end
    end
  end
end
