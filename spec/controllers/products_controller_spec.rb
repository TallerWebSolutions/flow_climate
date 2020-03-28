# frozen_string_literal: true

RSpec.describe ProductsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #portfolio_units_tab' do
      before { get :portfolio_units_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #risk_reviews_tab' do
      before { get :risk_reviews_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #service_delivery_reviews_tab' do
      before { get :service_delivery_reviews_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #projects_tab' do
      before { get :projects_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #index' do
      context 'having data' do
        let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
        let(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

        let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
        let!(:other_product) { Fabricate :product, customer: other_customer, name: 'aaa' }
        let!(:other_company_product) { Fabricate :product }

        before { get :index, params: { company_id: company } }

        it 'assigns the instance variable and renders the template' do
          expect(assigns(:products)).to eq [other_product, product]
          expect(assigns(:start_date)).to eq 3.months.ago.to_date
          expect(assigns(:end_date)).to eq Time.zone.today
          expect(assigns(:period)).to eq 'month'
          expect(response).to render_template :index
        end
      end

      context 'having no data' do
        before { get :index, params: { company_id: company } }

        it 'assigns empty to the instance variable and renders the template' do
          expect(assigns(:products)).to eq []
          expect(response).to render_template :index
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }

        it 'instantiates a new Product and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:product)).to be_a_new Product
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
        let(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

        before { post :create, params: { company_id: company, product: { customer_id: customer, name: 'foo' } } }

        it 'creates the new product and redirects to its show' do
          expect(Product.last.customer).to eq customer
          expect(Product.last.name).to eq 'foo'
          expect(response).to redirect_to company_products_path(company)
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, product: { customer_id: '', name: '' } } }

        it 'does not create the product and re-render the template with the errors' do
          expect(Product.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:product).errors.full_messages).to match_array ['Nome não pode ficar em branco', 'Cliente não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let!(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

      let(:product) { Fabricate :product, customer: customer }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: product } }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:company_customers)).to eq [other_customer, customer]
        end
      end

      context 'invalid' do
        context 'product' do
          before { get :edit, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: product } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, id: product } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let!(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

      let(:product) { Fabricate :product, customer: customer }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: product, product: { customer_id: customer, name: 'foo' } } }

        it 'updates the product and redirects to projects index' do
          expect(Product.last.customer).to eq customer
          expect(Product.last.name).to eq 'foo'

          expect(response).to redirect_to company_products_path(company)
        end
      end

      context 'passing invalid' do
        context 'product parameters' do
          before { put :update, params: { company_id: company, id: product, product: { customer_id: 'foo', name: '' } } }

          it 'does not update the product and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:company_customers)).to eq [other_customer, customer]
            expect(assigns(:product).errors.full_messages).to match_array ['Cliente não pode ficar em branco', 'Nome não pode ficar em branco']
          end
        end

        context 'non-existent product' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: 'foo', product: { customer_id: customer, name: 'foo' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: product, product: { customer_id: customer, name: 'foo' } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }

      let(:product) { Fabricate :product, customer: customer }

      let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'zzz' }
      let!(:other_jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'aaa' }

      context 'passing a valid ID' do
        context 'having data' do
          before { get :show, params: { company_id: company, id: product } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:product)).to eq product
            expect(assigns(:start_date)).to eq 3.months.ago.to_date
            expect(assigns(:end_date)).to eq Time.zone.today
            expect(assigns(:period)).to eq 'month'
            expect(assigns(:jira_product_configs)).to eq [other_jira_product_config, jira_product_config]
          end
        end

        context 'having no data' do
          let(:empty_product) { Fabricate :product, customer: customer }

          before { get :show, params: { company_id: company, id: empty_product } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:product)).to eq empty_product
          end
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', id: product } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: company, id: product } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #products_for_customer' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'valid parameters' do
        context 'having data' do
          let!(:first_product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:second_product) { Fabricate :product, customer: customer, name: 'aaa' }
          let!(:third_product) { Fabricate :product, name: 'aaa' }

          before { get :products_for_customer, params: { company_id: company, customer_id: customer }, xhr: true }

          it 'assigns the instance variable and renders the templates' do
            expect(assigns(:products)).to eq [second_product, first_product]
            expect(response).to render_template 'products/products.js.erb'
            expect(response).to render_template 'products/_products_table'
          end
        end

        context 'having no data' do
          before { get :products_for_customer, params: { company_id: company, customer_id: customer }, xhr: true }

          it 'assigns the instance variable as empty array and renders the templates' do
            expect(assigns(:products)).to eq []
            expect(response).to render_template 'products/products.js.erb'
            expect(response).to render_template 'products/_products_table'
          end
        end
      end

      context 'invalid parameters' do
        context 'no customer passed' do
          before { get :products_for_customer, params: { company_id: company }, xhr: true }

          it 'assigns the instance variable as empty array and renders the templates' do
            expect(assigns(:products)).to eq []
            expect(response).to render_template 'products/products.js.erb'
            expect(response).to render_template 'products/_products_table'
          end
        end

        context 'unpermitted company' do
          let(:unpermitted_company) { Fabricate :company }

          before { get :products_for_customer, params: { company_id: unpermitted_company }, xhr: true }

          it { expect(response.status).to eq 404 }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: product } }

          it 'deletes the product and redirects' do
            expect(flash[:error]).to be_nil
            expect(flash[:notice]).to eq I18n.t('general.destroy.success')
            expect(response).to redirect_to company_products_path(company)
            expect(Product.last).to be_nil
          end
        end
      end

      context 'invalid' do
        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: product } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, id: product } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'having dependencies' do
          let!(:demand) { Fabricate :demand, product: product }

          before { delete :destroy, params: { company_id: company, id: product } }

          it 'redirects to the products index showing the error' do
            expect(flash[:error]).to eq 'Não é possível excluir o registro pois existem demandas dependentes'
            expect(flash[:notice]).to be_nil
            expect(response).to redirect_to company_products_path(company)
          end
        end
      end
    end

    describe 'GET #portfolio_units_tab' do
      let(:customer) { Fabricate :customer, company: company }

      let!(:first_product) { Fabricate :product, customer: customer }
      let!(:second_product) { Fabricate :product, customer: customer }

      context 'with valid parameters' do
        context 'having data' do
          let!(:root_portfolio_unit) { Fabricate :portfolio_unit, product: first_product, name: 'root unit' }
          let!(:child_portfolio_unit) { Fabricate :portfolio_unit, product: first_product, parent: root_portfolio_unit, name: 'child unit' }
          let!(:grandchild_portfolio_unit) { Fabricate :portfolio_unit, product: first_product, parent: child_portfolio_unit, name: 'grandchild unit' }

          let!(:other_portfolio_unit) { Fabricate :portfolio_unit, product: second_product, name: 'other unit' }

          it 'creates the objects and renders the tab' do
            get :portfolio_units_tab, params: { company_id: company, id: first_product }, xhr: true
            expect(response).to render_template 'portfolio_units/portfolio_units_tab'
            expect(assigns(:portfolio_units)).to eq [child_portfolio_unit, grandchild_portfolio_unit, root_portfolio_unit]
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          get :portfolio_units_tab, params: { company_id: company, id: first_product }, xhr: true
          expect(assigns(:portfolio_units)).to eq []
          expect(response).to render_template 'portfolio_units/portfolio_units_tab'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :portfolio_units_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :portfolio_units_tab, params: { company_id: 'foo', id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :portfolio_units_tab, params: { company_id: company, id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #projects_tab' do
      let(:customer) { Fabricate :customer, company: company }

      let!(:first_product) { Fabricate :product, customer: customer }
      let!(:second_product) { Fabricate :product, customer: customer }

      context 'with valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, products: [first_product, second_product], end_date: 1.day.ago }
          let!(:second_project) { Fabricate :project, products: [first_product], end_date: Time.zone.today }

          let!(:other_project) { Fabricate :project, products: [second_product] }

          it 'creates the objects and renders the tab' do
            get :projects_tab, params: { company_id: company, id: first_product }, xhr: true
            expect(response).to render_template 'projects/projects_tab'
            expect(assigns(:projects_summary)).to be_a ProjectsSummaryData
            expect(assigns(:projects)).to eq [second_project, first_project]
            expect(assigns(:start_date)).to eq 3.months.ago.to_date
            expect(assigns(:end_date)).to eq Time.zone.today
            expect(assigns(:period)).to eq 'month'
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          get :projects_tab, params: { company_id: company, id: first_product }, xhr: true
          expect(assigns(:projects)).to eq []
          expect(response).to render_template 'projects/projects_tab'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :projects_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :projects_tab, params: { company_id: 'foo', id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :projects_tab, params: { company_id: company, id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #portfolio_charts_tab' do
      let(:customer) { Fabricate :customer, company: company }

      let!(:first_product) { Fabricate :product, customer: customer }
      let!(:second_product) { Fabricate :product, customer: customer }

      context 'with valid parameters' do
        context 'having data' do
          let!(:first_demand) { Fabricate :demand, product: first_product, end_date: 1.day.ago }
          let!(:second_demand) { Fabricate :demand, product: first_product, end_date: Time.zone.today }
          let!(:third_demand) { Fabricate :demand, product: first_product, end_date: nil }

          let!(:other_demand) { Fabricate :demand, product: second_product }

          it 'creates the objects and renders the tab' do
            get :portfolio_charts_tab, params: { company_id: company, id: first_product }, xhr: true
            expect(response).to render_template 'portfolio_units/portfolio_charts_tab'
            expect(assigns(:demands)).to eq [third_demand, second_demand, first_demand]
            expect(assigns(:start_date)).to eq [third_demand, second_demand, first_demand].map(&:created_date).compact.min.to_date
            expect(assigns(:end_date)).to eq Time.zone.today
            expect(assigns(:period)).to eq 'month'
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          get :portfolio_charts_tab, params: { company_id: company, id: first_product }, xhr: true
          expect(assigns(:demands)).to eq []
          expect(response).to render_template 'portfolio_units/portfolio_charts_tab'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :portfolio_charts_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :portfolio_charts_tab, params: { company_id: 'foo', id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :portfolio_charts_tab, params: { company_id: company, id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #risk_reviews_tab' do
      let(:customer) { Fabricate :customer, company: company }

      let!(:first_product) { Fabricate :product, customer: customer }
      let!(:second_product) { Fabricate :product, customer: customer }

      context 'with valid parameters' do
        context 'having data' do
          let!(:first_risk) { Fabricate :risk_review, product: first_product, meeting_date: 1.day.ago }
          let!(:second_risk) { Fabricate :risk_review, product: first_product, meeting_date: Time.zone.today }

          let!(:other_risk) { Fabricate :risk_review, product: second_product }

          it 'creates the objects and renders the tab' do
            get :risk_reviews_tab, params: { company_id: company, id: first_product }, xhr: true
            expect(response).to render_template 'risk_reviews/risk_reviews_tab'
            expect(assigns(:risk_reviews)).to eq [second_risk, first_risk]
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          get :risk_reviews_tab, params: { company_id: company, id: first_product }, xhr: true
          expect(assigns(:risk_reviews)).to eq []
          expect(response).to render_template 'risk_reviews/risk_reviews_tab'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :risk_reviews_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :risk_reviews_tab, params: { company_id: 'foo', id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :risk_reviews_tab, params: { company_id: company, id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #service_delivery_reviews_tab' do
      let(:customer) { Fabricate :customer, company: company }

      let!(:first_product) { Fabricate :product, customer: customer }
      let!(:second_product) { Fabricate :product, customer: customer }

      context 'with valid parameters' do
        context 'having data' do
          let!(:first_service_delivery) { Fabricate :service_delivery_review, product: first_product, meeting_date: 1.day.ago }
          let!(:second_service_delivery) { Fabricate :service_delivery_review, product: first_product, meeting_date: Time.zone.today }

          let!(:other_service_delivery) { Fabricate :service_delivery_review, product: second_product }

          it 'creates the objects and renders the tab' do
            get :service_delivery_reviews_tab, params: { company_id: company, id: first_product }, xhr: true
            expect(response).to render_template 'service_delivery_reviews/service_delivery_reviews_tab'
            expect(assigns(:service_delivery_reviews)).to eq [second_service_delivery, first_service_delivery]
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          get :service_delivery_reviews_tab, params: { company_id: company, id: first_product }, xhr: true
          expect(assigns(:service_delivery_reviews)).to eq []
          expect(response).to render_template 'service_delivery_reviews/service_delivery_reviews_tab'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :service_delivery_reviews_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :service_delivery_reviews_tab, params: { company_id: 'foo', id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :service_delivery_reviews_tab, params: { company_id: company, id: first_product } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
