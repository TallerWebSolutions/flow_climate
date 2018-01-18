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
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }
    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #index' do
      context 'having data' do
        let(:customer) { Fabricate :customer, company: company }
        let(:other_customer) { Fabricate :customer, company: company }

        let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
        let(:other_product) { Fabricate :product, customer: other_customer, name: 'aaa' }

        let(:other_company_product) { Fabricate :product }

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
          expect(assigns(:product).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Cliente não pode ficar em branco']
        end
      end
    end
  end
end
