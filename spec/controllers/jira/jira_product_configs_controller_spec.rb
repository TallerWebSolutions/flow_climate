# frozen_string_literal: true

RSpec.describe Jira::JiraProductConfigsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', product_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let!(:product) { Fabricate :product, company: company, customer: customer }

    describe 'GET #index' do
      context 'valid parameters' do
        it 'assigns the instance variable and renders the template' do
          config = Fabricate :jira_product_config, product: product

          get :index, params: { company_id: company, product_id: product }

          expect(response).to render_template :index
          expect(assigns(:jira_product_configs)).to eq [config]
        end
      end

      context 'invalid parameters' do
        context 'non-existent product' do
          before { get :new, params: { company_id: company, product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

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

    describe 'GET #new' do
      context 'valid parameters' do
        it 'instantiates a new product jira config and renders the template' do
          get :new, params: { company_id: company, product_id: product }

          expect(response).to render_template 'jira/jira_product_configs/new'
          expect(assigns(:jira_product_config)).to be_a_new Jira::JiraProductConfig
        end
      end

      context 'invalid parameters' do
        context 'non-existent product' do
          before { get :new, params: { company_id: company, product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

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

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, product_id: product, jira_jira_product_config: { jira_product_key: 'xpto' } } }

        it 'creates the new product jira config' do
          created_config = Jira::JiraProductConfig.last
          expect(created_config.jira_product_key).to eq 'xpto'
          expect(created_config.product).to eq product
          expect(created_config.company).to eq company

          expect(response).to redirect_to company_product_jira_product_configs_path(company, product)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, product_id: product, jira_jira_product_config: { jira_product_key: '' } }, xhr: true }

          it 'does not create the product jira config' do
            expect(Jira::JiraProductConfig.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:jira_product_config).errors.full_messages).to eq ['Chave do Produto no Jira não pode ficar em branco']
          end
        end

        context 'breaking unique index' do
          let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'xpto' }

          before { post :create, params: { company_id: company, product_id: product, jira_jira_product_config: { jira_product_key: 'xpto' } } }

          it 'does not create the product jira config' do
            expect(Jira::JiraProductConfig.count).to eq 1
            expect(response).to render_template :new
            expect(assigns(:jira_product_config).errors_on(:jira_product_key)).to eq ['Deve haver apenas uma chave de produto no jira para cada produto']
            expect(flash[:error]).to eq 'Chave do Produto no Jira Deve haver apenas uma chave de produto no jira para cada produto'
          end
        end

        context 'non-existent product' do
          before { post :create, params: { company_id: company, product_id: 'foo', jira_jira_product_config: { jira_product_key: '' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { post :create, params: { company_id: 'foo', product_id: product, jira_jira_product_config: { jira_product_key: '' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { post :create, params: { company_id: company, product_id: product, jira_jira_product_config: { jira_product_key: '' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:jira_product_config) { Fabricate :jira_product_config, product: product }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, product_id: product, id: jira_product_config } }

        it 'deletes the jira config' do
          expect(response).to redirect_to company_product_jira_product_configs_path(company, product)
          expect(Jira::JiraProductConfig.last).to be_nil
        end
      end

      context 'invalid parameters' do
        context 'non-existent product jira config' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', id: jira_product_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, id: jira_product_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, id: jira_product_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
