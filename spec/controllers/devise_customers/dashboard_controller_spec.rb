# frozen_string_literal: true

RSpec.describe DeviseCustomers::DashboardController do
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
  end
end
