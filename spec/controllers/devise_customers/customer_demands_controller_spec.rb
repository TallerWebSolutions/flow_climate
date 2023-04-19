# frozen_string_literal: true

RSpec.describe DeviseCustomers::CustomerDemandsController do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_devise_customer_session_path }
    end

    describe 'POST #search' do
      before { post :search }

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

    describe 'POST #search' do
      context 'with valid data' do
        it 'searches the demands and updates the view' do
          travel_to Time.zone.local(2023, 4, 14, 10) do
            company = Fabricate :company
            customer = Fabricate :customer, company: company

            demand = Fabricate :demand, customer: customer, end_date: 24.hours.ago
            other_demand = Fabricate :demand, customer: customer, end_date: 23.hours.ago
            Fabricate :demand, customer: customer, end_date: 23.hours.ago, discarded_at: 1.day.ago
            Fabricate :demand, customer: customer, end_date: 11.days.ago
            Fabricate :demand, customer: customer, end_date: 72.hours.ago

            devise_customer.customers << customer

            post :search, params: { demands_start_date: 48.hours.ago, demands_end_date: 12.hours.ago }, xhr: true

            expect(response).to render_template 'devise_customers/customer_demands/_demands_table'
            expect(assigns(:customer_last_deliveries)).to eq [other_demand, demand]
            expect(assigns(:customer)).to eq customer
            expect(assigns(:company)).to eq company
          end
        end
      end

      context 'with valid customer' do
        it 'returns not_found' do
          post :search, params: { demands_start_date: 48.hours.ago, demands_end_date: 12.hours.ago }, xhr: true

          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
