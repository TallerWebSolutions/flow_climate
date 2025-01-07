# frozen_string_literal: true

RSpec.describe ServiceDeliveryReviewsController do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', product_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { login_as user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

    describe 'GET #show' do
      let(:service_delivery_review) { Fabricate :service_delivery_review, product: product }

      before { get :show, params: { company_id: company, product_id: product, id: service_delivery_review } }

      it 'renders the template' do
        expect(response).to render_template 'spa-build/index'
      end
    end
  end
end
