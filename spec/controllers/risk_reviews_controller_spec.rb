# frozen_string_literal: true

RSpec.describe RiskReviewsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', product_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', product_id: 'bar', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, product_id: product }, xhr: true }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template 'risk_reviews/new.js.erb'
          expect(assigns(:risk_review)).to be_a_new RiskReview
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:risk_review) { Fabricate :risk_review, product: product }
      let(:other_risk_review) { Fabricate :risk_review }

      context 'valid parameters' do
        before { get :show, params: { company_id: company, product_id: product, id: risk_review } }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template :show
          expect(assigns(:risk_review)).to eq risk_review
        end
      end

      context 'invalid parameters' do
        context 'invalid risk review' do
          before { get :show, params: { company_id: company, product_id: product, id: other_risk_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', product_id: product, id: risk_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: company, product_id: product, id: risk_review } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let(:risk_review) { Fabricate :risk_review, product: product, meeting_date: 1.year.ago }

        let!(:first_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: 2.days.ago }
        let!(:second_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: 26.hours.ago }
        let!(:third_demand) { Fabricate :demand, product: product, risk_review: risk_review, end_date: 26.hours.ago }
        let!(:fourth_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: 4.days.ago }
        let!(:fifth_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: Time.zone.tomorrow }

        let!(:first_block) { Fabricate :demand_block, demand: first_demand, risk_review: nil, unblock_time: 2.days.ago }
        let!(:second_block) { Fabricate :demand_block, demand: first_demand, risk_review: nil, unblock_time: 26.hours.ago }
        let!(:third_block) { Fabricate :demand_block, demand: second_demand, risk_review: risk_review, unblock_time: 26.hours.ago }
        let!(:fourth_block) { Fabricate :demand_block, demand: third_demand, risk_review: nil, unblock_time: 4.days.ago }
        let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, risk_review: nil, unblock_time: Time.zone.tomorrow }

        let!(:start_date) { 3.days.ago }
        let!(:end_date) { 1.day.ago }

        before { post :create, params: { company_id: company, product_id: product, risk_review: { meeting_date: Time.zone.today, lead_time_outlier_limit: 10 } }, xhr: true }

        it 'creates the new team member and redirects to team show' do
          expect(response).to render_template 'risk_reviews/create.js.erb'
          expect(assigns(:risk_review).errors.full_messages).to eq []
          expect(assigns(:risk_review)).to be_persisted
          expect(assigns(:risk_review).lead_time_outlier_limit).to eq 10
          expect(assigns(:risk_review).demands).to match_array [first_demand, second_demand, fourth_demand]
          expect(assigns(:risk_review).demand_blocks).to match_array [first_block, second_block, fourth_block]
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, product_id: product, risk_review: { meeting_date: nil, lead_time_outlier_limit: nil } }, xhr: true }

        it 'does not create the team member and re-render the template with the errors' do
          expect(RiskReview.all.count).to eq 0
          expect(response).to render_template 'risk_reviews/create.js.erb'
          expect(assigns(:risk_review).errors.full_messages).to eq ['Outlier no lead time não pode ficar em branco', 'Data da Reunião não pode ficar em branco']
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer }
      let!(:risk_review) { Fabricate :risk_review, product: product }
      let!(:other_risk_review) { Fabricate :risk_review }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: risk_review }, xhr: true }

          it 'deletes the product and redirects' do
            expect(response).to render_template 'risk_reviews/destroy'
            expect(RiskReview.all).to eq [other_risk_review]
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', id: risk_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'other product' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: other_risk_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, id: risk_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, id: risk_review } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
