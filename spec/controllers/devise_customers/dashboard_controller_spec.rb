# frozen_string_literal: true

RSpec.describe DeviseCustomers::DashboardController do
  context 'unauthenticated' do
    describe 'GET #home' do
      before { get :home }

      it { expect(response).to redirect_to new_devise_customer_session_path }
    end

    describe 'GET #search' do
      before { post :search }

      it { expect(response).to redirect_to new_devise_customer_session_path }
    end
  end

  context 'authenticated' do
    let(:devise_customer) { Fabricate :devise_customer }

    before { sign_in devise_customer }

    describe 'GET #home' do
      context 'with a customer with consolidations' do
        it 'renders the no data layout' do
          travel_to Time.zone.local(2022, 11, 18, 10) do
            customer = Fabricate :customer, devise_customers: [devise_customer]
            contract = Fabricate :contract, customer: customer

            consolidation = Fabricate :customer_consolidation, customer: customer, consolidation_date: Time.zone.now, last_data_in_month: true
            other_consolidation = Fabricate :customer_consolidation, customer: customer, consolidation_date: 1.day.ago, last_data_in_month: true
            Fabricate :customer_consolidation, customer: customer, consolidation_date: 2.days.ago, last_data_in_month: false

            first_demand = Fabricate :demand, customer: customer, end_date: 1.hour.ago
            second_demand = Fabricate :demand, customer: customer, end_date: Time.zone.now

            get :home

            expect(response).to render_template 'dashboard/home'
            expect(response).not_to render_template 'layouts/_no_data'
            expect(assigns(:customer_consolidations)).to eq [other_consolidation, consolidation]
            expect(assigns(:contracts)).to eq [contract]
            expect(assigns(:customer_last_deliveries)).to eq [second_demand, first_demand]
          end
        end
      end

      context 'with no customer' do
        before { get :home }

        it { expect(response).to have_http_status :not_found }
      end
    end

    describe 'GET #search' do
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

            get :search, params: { demands_start_date: 48.hours.ago, demands_end_date: 12.hours.ago }, xhr: true

            expect(response).to render_template 'devise_customers/customer_demands/_demands_table'
            expect(assigns(:customer_last_deliveries)).to eq [other_demand, demand]
            expect(assigns(:customer)).to eq customer
            expect(assigns(:company)).to eq company
          end
        end
      end

      context 'with valid customer' do
        it 'returns not_found' do
          get :search, params: { demands_start_date: 48.hours.ago, demands_end_date: 12.hours.ago }, xhr: true

          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
