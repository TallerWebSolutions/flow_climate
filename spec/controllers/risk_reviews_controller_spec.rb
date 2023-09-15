# frozen_string_literal: true

RSpec.describe RiskReviewsController do
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

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', product_id: 'bar', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', product_id: 'bar', id: 'xpto' } }

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
    let(:product) { Fabricate :product, company: company, customer: customer }

    describe 'GET #new' do
      context 'valid parameters' do
        it 'renders project spa page' do
          get :new, params: { company_id: company, product_id: product }

          expect(response).to render_template 'spa-build/index'
        end
      end
    end

    describe 'GET #show' do
      context 'with valid parameters' do
        context 'with no data to blockings' do
          it 'instantiates a new Team Member and renders the template' do
            stage = Fabricate :stage, company: company
            allow_any_instance_of(Demand).to(receive(:stage_at)).and_return(stage)
            demand = Fabricate :demand
            demand_block = Fabricate :demand_block, demand: demand

            risk_review = Fabricate :risk_review, product: product, demands: [demand], demand_blocks: [demand_block]

            get :show, params: { company_id: company, product_id: product, id: risk_review }

            expect(response).to render_template 'spa-build/index'
          end
        end

        context 'with data to blockings' do
          let(:risk_review) { Fabricate :risk_review, product: product, weekly_avg_blocked_time: [2, 3, 5], monthly_avg_blocked_time: [1, 2] }

          before { get :show, params: { company_id: company, product_id: product, id: risk_review } }

          it 'instantiates a new Team Member and renders the template' do
            expect(response).to render_template 'spa-build/index'
          end
        end
      end

      context 'invalid parameters' do
        let(:risk_review) { Fabricate :risk_review, product: product }
        let(:other_risk_review) { Fabricate :risk_review }

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
        let!(:first_risk) { Fabricate :risk_review, product: product, meeting_date: 3.days.ago }
        let!(:second_risk) { Fabricate :risk_review, product: product, meeting_date: 2.days.ago }

        it 'creates the new risk review' do
          expect(RiskReviewGeneratorJob).to receive(:perform_later).once
          post :create, params: { company_id: company, product_id: product, risk_review: { meeting_date: Time.zone.today, lead_time_outlier_limit: 10 } }, xhr: true

          expect(response).to render_template 'risk_reviews/create'
          expect(assigns(:risk_review).errors.full_messages).to eq []
          expect(assigns(:risk_review)).to be_persisted
          expect(assigns(:risk_review).lead_time_outlier_limit).to eq 10
          expect(assigns(:risk_reviews)).to eq product.reload.risk_reviews.order(meeting_date: :desc)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          it 'does not create the review and re-render the template with the errors' do
            expect(RiskReviewGeneratorJob).not_to receive(:perform_later)
            post :create, params: { company_id: company, product_id: product, risk_review: { meeting_date: nil, lead_time_outlier_limit: nil } }, xhr: true

            expect(RiskReview.count).to eq 0
            expect(response).to render_template 'risk_reviews/create'
            expect(assigns(:risk_review).errors.full_messages).to eq ['Outlier no lead time não pode ficar em branco', 'Data da Reunião não pode ficar em branco']
          end

          context 'company' do
            before { post :create, params: { company_id: 'foo', product_id: product }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'product' do
            before { post :create, params: { company_id: company, product_id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted company' do
            let(:company) { Fabricate :company, users: [] }

            before { post :create, params: { company_id: company, product_id: product }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, company: company, customer: customer }
      let!(:risk_review) { Fabricate :risk_review, product: product }
      let!(:other_risk_review) { Fabricate :risk_review }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: risk_review }, xhr: true }

          it 'deletes the risk review and renders the template' do
            expect(response).to render_template 'risk_reviews/destroy'
            expect(response).to render_template 'risk_reviews/_risk_reviews_table'
            expect(RiskReview.all).to eq [other_risk_review]
          end
        end
      end

      context 'invalid' do
        context 'non-existent risk review' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

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

    describe 'GET #edit' do
      let!(:first_risk) { Fabricate :risk_review, product: product, meeting_date: 1.day.ago }
      let!(:second_risk) { Fabricate :risk_review, product: product, meeting_date: Time.zone.today }

      context 'passing valid parameters' do
        before { get :edit, params: { company_id: company, product_id: product, id: first_risk }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(response).to have_http_status :ok
          expect(response).to render_template 'risk_reviews/edit'
          expect(assigns(:risk_review)).to eq first_risk
          expect(assigns(:risk_reviews)).to eq [second_risk, first_risk]
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :edit, params: { company_id: 'foo', product_id: product, id: first_risk }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { get :edit, params: { company_id: company, product_id: 'foo', id: first_risk }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'risk_review' do
          before { get :edit, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #update' do
      let!(:first_risk) { Fabricate :risk_review, product: product, meeting_date: 1.day.ago }
      let!(:second_risk) { Fabricate :risk_review, product: product, meeting_date: Time.zone.today }

      context 'passing valid parameters' do
        it 'updates the risk review and renders the template' do
          expect(RiskReviewGeneratorJob).to receive(:perform_later).once
          put :update, params: { company_id: company, product_id: product, id: first_risk, risk_review: { meeting_date: Time.zone.tomorrow, lead_time_outlier_limit: 10 } }, xhr: true

          expect(response).to render_template 'risk_reviews/update'
          expect(assigns(:risk_review).errors.full_messages).to eq []
          expect(assigns(:risk_review)).to be_persisted
          expect(assigns(:risk_review).lead_time_outlier_limit).to eq 10
          expect(assigns(:risk_reviews)).to eq [first_risk, second_risk]
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          it 'does not create the review and re-render the template with the errors' do
            expect(RiskReviewGeneratorJob).not_to receive(:perform_later)
            put :update, params: { company_id: company, product_id: product, id: first_risk, risk_review: { meeting_date: nil, lead_time_outlier_limit: nil } }, xhr: true

            expect(response).to render_template 'risk_reviews/update'
            expect(assigns(:risk_review).errors.full_messages).to eq ['Outlier no lead time não pode ficar em branco', 'Data da Reunião não pode ficar em branco']
          end
        end

        context 'company' do
          before { put :update, params: { company_id: 'foo', product_id: product, id: first_risk }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { put :update, params: { company_id: company, product_id: 'foo', id: first_risk }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'risk_review' do
          before { put :update, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
