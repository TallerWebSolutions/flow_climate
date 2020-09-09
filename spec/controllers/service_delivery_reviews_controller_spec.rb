# frozen_string_literal: true

RSpec.describe ServiceDeliveryReviewsController, type: :controller do
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

    describe 'PATCH #refresh' do
      before { patch :refresh, params: { company_id: 'foo', product_id: 'bar', id: 'xpto' } }

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
          expect(response).to render_template 'service_delivery_reviews/new.js.erb'
          expect(assigns(:service_delivery_review)).to be_a_new ServiceDeliveryReview
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
      let!(:other_service_delivery_review) { Fabricate :service_delivery_review }

      context 'with valid parameters' do
        context 'with data' do
          let(:project) { Fabricate :project, company: company, products: [product] }
          let(:ongoing_stage) { Fabricate :stage, company: company, projects: [project], end_point: false, stage_stream: :downstream }
          let(:end_stage) { Fabricate :stage, company: company, projects: [project], end_point: true }
          let(:demand) { Fabricate :demand, product: product, project: project }
          let!(:ongoing_demand_transition) { Fabricate :demand_transition, demand: demand, stage: ongoing_stage, last_time_in: 12.days.ago, last_time_out: 11.days.ago }
          let!(:end_demand_transition) { Fabricate :demand_transition, demand: demand, stage: end_stage, last_time_in: 10.days.ago, last_time_out: 1.day.ago }
          let(:service_delivery_review) { Fabricate :service_delivery_review, product: product, demands: [demand] }

          before { get :show, params: { company_id: company, product_id: product, id: service_delivery_review } }

          it 'instantiates a new Team Member and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:service_delivery_review)).to eq service_delivery_review
          end
        end

        context 'with no transitions data' do
          let(:project) { Fabricate :project, company: company, products: [product] }
          let(:demand) { Fabricate :demand, product: product, project: project }
          let(:service_delivery_review) { Fabricate :service_delivery_review, product: product, demands: [demand] }

          before { get :show, params: { company_id: company, product_id: product, id: service_delivery_review } }

          it 'instantiates a new Team Member and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:service_delivery_review)).to eq service_delivery_review
          end
        end

        context 'with no finished demands' do
          let(:project) { Fabricate :project, company: company, products: [product] }
          let(:demand) { Fabricate :demand, product: product, project: project, end_date: nil }
          let(:service_delivery_review) { Fabricate :service_delivery_review, product: product, demands: [demand] }

          before { get :show, params: { company_id: company, product_id: product, id: service_delivery_review } }

          it 'instantiates a new Team Member and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:service_delivery_review)).to eq service_delivery_review
          end
        end

        context 'with no demands' do
          let(:project) { Fabricate :project, company: company, products: [product] }
          let(:service_delivery_review) { Fabricate :service_delivery_review, product: product }

          before { get :show, params: { company_id: company, product_id: product, id: service_delivery_review } }

          it 'instantiates a new Team Member and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:service_delivery_review)).to eq service_delivery_review
          end
        end
      end

      context 'with invalid' do
        let(:service_delivery_review) { Fabricate :service_delivery_review, product: product }
        
        context 'service_delivery review' do
          before { get :show, params: { company_id: company, product_id: product, id: other_service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', product_id: product, id: service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: company, product_id: product, id: service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let!(:first_service_delivery) { Fabricate :service_delivery_review, product: product, meeting_date: 3.days.ago }
        let!(:second_service_delivery) { Fabricate :service_delivery_review, product: product, meeting_date: 2.days.ago }

        it 'creates the new service_delivery review' do
          expect(ServiceDeliveryReviewGeneratorJob).to receive(:perform_later).once
          post :create, params: { company_id: company, product_id: product, service_delivery_review: { meeting_date: Time.zone.tomorrow, delayed_expedite_bottom_threshold: 10, delayed_expedite_top_threshold: 20, expedite_max_pull_time_sla: 2, lead_time_bottom_threshold: 3, lead_time_top_threshold: 2, quality_bottom_threshold: 10, quality_top_threshold: 20 } }, xhr: true

          expect(response).to render_template 'service_delivery_reviews/create'
          expect(assigns(:service_delivery_review).errors.full_messages).to eq []
          expect(assigns(:service_delivery_review)).to be_persisted
          expect(assigns(:service_delivery_review).delayed_expedite_bottom_threshold).to eq 0.1
          expect(assigns(:service_delivery_reviews)).to eq product.reload.service_delivery_reviews.order(meeting_date: :desc)
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, product_id: product, service_delivery_review: { meeting_date: nil, lead_time_outlier_limit: nil } }, xhr: true }

        it 'does not create the team member and re-render the template with the errors' do
          expect(ServiceDeliveryReview.all.count).to eq 0
          expect(response).to render_template 'service_delivery_reviews/create'
          expect(assigns(:service_delivery_review).errors.full_messages).to eq ['Data da Reunião não pode ficar em branco']
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer }
      let!(:service_delivery_review) { Fabricate :service_delivery_review, product: product }
      let!(:other_service_delivery_review) { Fabricate :service_delivery_review }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: service_delivery_review }, xhr: true }

          it 'deletes the product and redirects' do
            expect(response).to render_template 'service_delivery_reviews/destroy'
            expect(ServiceDeliveryReview.all).to eq [other_service_delivery_review]
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', id: service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'other product' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: other_service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, id: service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, id: service_delivery_review } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let!(:first_service_delivery) { Fabricate :service_delivery_review, product: product, meeting_date: 1.day.ago }
      let!(:second_service_delivery) { Fabricate :service_delivery_review, product: product, meeting_date: Time.zone.today }

      let!(:first_demand) { Fabricate :demand, product: product, service_delivery_review: nil, end_date: 2.days.ago }
      let!(:second_demand) { Fabricate :demand, product: product, service_delivery_review: nil, end_date: 26.hours.ago }
      let!(:third_demand) { Fabricate :demand, product: product, service_delivery_review: first_service_delivery, end_date: 26.hours.ago }
      let!(:fourth_demand) { Fabricate :demand, product: product, service_delivery_review: nil, end_date: 4.days.ago }
      let!(:fifth_demand) { Fabricate :demand, product: product, service_delivery_review: nil, end_date: Time.zone.tomorrow }

      let!(:start_date) { 3.days.ago }
      let!(:end_date) { 1.day.ago }

      context 'passing valid parameters' do
        before { get :edit, params: { company_id: company, product_id: product, id: first_service_delivery }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(response).to have_http_status :ok
          expect(response).to render_template 'service_delivery_reviews/edit'
          expect(assigns(:service_delivery_review)).to eq first_service_delivery
          expect(assigns(:service_delivery_reviews)).to eq [second_service_delivery, first_service_delivery]
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :edit, params: { company_id: 'foo', product_id: product, id: first_service_delivery }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { get :edit, params: { company_id: company, product_id: 'foo', id: first_service_delivery }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'service_delivery_review' do
          before { get :edit, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #update' do
      let!(:first_service_delivery) { Fabricate :service_delivery_review, product: product, meeting_date: 1.day.ago }
      let!(:second_service_delivery) { Fabricate :service_delivery_review, product: product, meeting_date: Time.zone.today }

      context 'passing valid parameters' do
        it 'assigns the instance variable and renders the template' do
          expect(ServiceDeliveryReviewGeneratorJob).to receive(:perform_later).once
          put :update, params: { company_id: company, product_id: product, id: first_service_delivery, service_delivery_review: { meeting_date: Time.zone.tomorrow, delayed_expedite_bottom_threshold: 10, delayed_expedite_top_threshold: 20, expedite_max_pull_time_sla: 2, lead_time_bottom_threshold: 3, lead_time_top_threshold: 2, quality_bottom_threshold: 10, quality_top_threshold: 20 } }, xhr: true

          expect(response).to render_template 'service_delivery_reviews/update'
          expect(assigns(:service_delivery_review).errors.full_messages).to eq []
          expect(assigns(:service_delivery_review)).to be_valid
          expect(assigns(:service_delivery_review).delayed_expedite_bottom_threshold).to eq 0.1
          expect(assigns(:service_delivery_reviews)).to eq product.reload.service_delivery_reviews.order(meeting_date: :desc)
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { put :update, params: { company_id: 'foo', product_id: product, id: first_service_delivery }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { put :update, params: { company_id: company, product_id: 'foo', id: first_service_delivery }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'service_delivery_review' do
          before { put :update, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #refresh' do
      let(:demand) { Fabricate :demand, product: product }
      let(:service_delivery_review) { Fabricate :service_delivery_review, product: product, demands: [demand], meeting_date: Time.zone.now }

      context 'with valid data' do
        it 'updates the information in the service delivery review' do
          expect(ServiceDeliveryReviewGeneratorJob).to receive(:perform_later).once
          patch :refresh, params: { company_id: company, product_id: product, id: service_delivery_review }, xhr: true

          expect(response).to render_template 'service_delivery_reviews/update'
        end
      end

      context 'with invalid' do
        context 'service delivery review' do
          before { patch :refresh, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { patch :refresh, params: { company_id: company, product_id: 'foo', id: service_delivery_review }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'not found' do
            before { patch :refresh, params: { company_id: 'foo', product_id: product, id: service_delivery_review }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :refresh, params: { company_id: company, product_id: product, id: service_delivery_review }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
