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
    describe 'GET #search_for_projects' do
      before { get :search_for_projects, params: { company_id: 'foo', id: 'foo', status_filter: :executing }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }
    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #index' do
      context 'having data' do
        let(:customer) { Fabricate :customer, company: company }
        let(:other_customer) { Fabricate :customer, company: company }

        let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
        let!(:other_product) { Fabricate :product, customer: other_customer, name: 'aaa' }
        let!(:other_company_product) { Fabricate :product }

        before { get :index, params: { company_id: company } }
        it 'assigns the instance variable and renders the template' do
          expect(assigns(:products)).to eq [other_product, product]
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
        let(:customer) { Fabricate :customer, company: company }
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
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: product } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
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
      let(:customer) { Fabricate :customer, company: company }
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
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:first_project) { Fabricate :project, customer: product.customer, product: product, end_date: 5.days.from_now }
      let!(:second_project) { Fabricate :project, customer: product.customer, product: product, end_date: 7.days.from_now }

      context 'passing a valid ID' do
        context 'having data' do
          before { get :show, params: { company_id: company, id: product } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:product)).to eq product
            expect(assigns(:report_data)).to be_a ReportData
            expect(assigns(:product_projects)).to eq [second_project, first_project]
          end
        end
        context 'having no data' do
          let(:empty_product) { Fabricate :product, customer: customer }
          before { get :show, params: { company_id: company, id: empty_product } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:product)).to eq empty_product
            expect(assigns(:report_data)).to be_nil
            expect(assigns(:product_projects)).to eq []
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
            expect(response).to redirect_to company_products_path(company)
            expect(Product.last).to be_nil
          end
        end
        context 'having dependencies' do
          let!(:project) { Fabricate :project, product: product, customer: product.customer }
          before { delete :destroy, params: { company_id: company, id: product } }

          it 'does not delete the product and show the error' do
            expect(response).to redirect_to company_products_path(company)
            expect(Product.last).to eq product
            expect(flash[:error]).to eq assigns(:product).errors.full_messages.join(',')
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent operation result' do
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
      end
    end

    describe '#search_for_projects' do
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, company: company }
      let(:other_product) { Fabricate :product, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 10.days.from_now }
          let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 50.days.from_now }
          let!(:third_project) { Fabricate :project, customer: customer, product: product, status: :waiting, end_date: 15.days.from_now }
          let!(:other_product_project) { Fabricate :project, status: :executing }

          context 'and passing a status filter' do
            before { get :search_for_projects, params: { company_id: company, id: product, status_filter: :executing }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, first_project]
            end
          end
          context 'and passing no status filter' do
            before { get :search_for_projects, params: { company_id: company, id: product, status_filter: :all }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, third_project, first_project]
            end
          end
        end
        context 'having no data' do
          let!(:other_company_project) { Fabricate :project, status: :executing }

          before { get :search_for_projects, params: { company_id: company, id: product, status_filter: :executing }, xhr: true }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template 'projects/projects_search.js.erb'
            expect(assigns(:projects)).to eq []
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :search_for_projects, params: { company_id: 'foo', id: product, status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'product' do
          before { get :search_for_projects, params: { company_id: company, id: 'foo', status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :search_for_projects, params: { company_id: company, id: product, status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
