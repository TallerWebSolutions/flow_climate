# frozen_string_literal: true

RSpec.describe Jira::JiraProjectConfigsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', project_id: 'foo' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', project_id: 'foo' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', project_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'PUT #synchronize_jira' do
      before { put :synchronize_jira, params: { company_id: 'foo', project_id: 'xpto', id: 'bar' }, xhr: true }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'bar', project_id: 'foo' } }

      it { expect(response).to redirect_to new_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { login_as user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let!(:product) { Fabricate :product, company: company, customer: customer }

    describe 'GET #new' do
      let!(:project) { Fabricate :project, customers: [customer], products: [product] }

      let!(:jira_product_config) { Fabricate :jira_product_config, product: product }
      let!(:other_jira_product_config) { Fabricate :jira_product_config, product: product }
      let!(:out_jira_product_config) { Fabricate :jira_product_config }

      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project } }

        it 'instantiates a new project jira config and renders the template' do
          expect(response).to render_template 'jira/jira_project_configs/new'
          expect(assigns(:jira_project_config)).to be_a_new Jira::JiraProjectConfig
          expect(assigns(:jira_product_configs)).to match_array [jira_product_config, other_jira_product_config]
        end
      end

      context 'invalid parameters' do
        context 'non-existent project' do
          before { get :new, params: { company_id: company, project_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let!(:project) { Fabricate :project, customers: [customer], products: [product] }
      let(:jira_product_config) { Fabricate :jira_product_config, product: product, company: product.company, jira_product_key: 'bar' }
      let!(:jira_project_config) { Fabricate :jira_project_config, project: project }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { fix_version_name: 'xpto', jira_product_config_id: jira_product_config.id } } }

        it 'creates the new project jira config' do
          created_config = Jira::JiraProjectConfig.last
          expect(created_config.fix_version_name).to eq 'xpto'
          expect(created_config.jira_product_config).to eq jira_product_config

          expect(response).to redirect_to company_project_jira_project_configs_path(company, project)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { name: '' } } }

          it 'does not create the project jira config' do
            expect(project.reload.jira_project_configs).to eq [jira_project_config]
            expect(response).to redirect_to company_project_jira_project_configs_path(company, project)
            expect(assigns(:jira_project_config).errors.full_messages).to eq ['Config do Produto deve existir', 'Fix Version ou Label no Jira não pode ficar em branco']
          end
        end

        context 'breaking unique index' do
          let!(:jira_project_config) { Fabricate :jira_project_config, jira_product_config: jira_product_config, fix_version_name: 'xpto' }

          before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { jira_product_config_id: jira_product_config, fix_version_name: 'xpto' } } }

          it 'does not create the project jira config' do
            expect(Jira::JiraProjectConfig.count).to eq 1
            expect(response).to redirect_to company_project_jira_project_configs_path(company, project)
            expect(assigns(:jira_project_config).errors_on(:fix_version_name)).to eq [I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message')]
            expect(flash[:error]).to eq I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message')
          end
        end

        context 'non-existent project' do
          before { post :create, params: { company_id: company, project_id: 'foo', jira_jira_project_config: { name: '' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { post :create, params: { company_id: 'foo', project_id: project, jira_jira_project_config: { name: '' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { name: '' } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:project) { Fabricate :project, customers: [customer], products: [product] }

      let!(:jira_project_config) { Fabricate :jira_project_config, project: project }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, project_id: project, id: jira_project_config }, xhr: true }

        it 'deletes the jira config' do
          expect(response).to redirect_to company_project_jira_project_configs_path(company, project)
          expect(flash[:notice]).to eq I18n.t('general.destroy.success')
          expect(Jira::JiraProjectConfig.last).to be_nil
        end
      end

      context 'invalid parameters' do
        context 'non-existent project jira config' do
          before { delete :destroy, params: { company_id: company, project_id: project, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, project_id: 'foo', id: jira_project_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', project_id: project, id: jira_project_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, project_id: project, id: jira_project_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #synchronize_jira' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customers: [customer] }
      let!(:jira_config) { Fabricate :jira_project_config, project: project }

      context 'passing valid parameters' do
        it 'calls the job and enqueues the sync' do
          expect(Jira::ProcessJiraProjectJob).to receive(:perform_later).once
          put :synchronize_jira, params: { company_id: company, project_id: project, id: jira_config }, xhr: true
          expect(response).to render_template 'jira/jira_project_configs/synchronize_jira'
          expect(flash[:notice]).to eq I18n.t('general.enqueued')
        end
      end

      context 'invalid' do
        let(:project) { Fabricate :project, customers: [customer] }

        context 'project' do
          before { put :synchronize_jira, params: { company_id: company, project_id: 'foo', id: jira_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'jira project config' do
          before { put :synchronize_jira, params: { company_id: company, project_id: project, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { put :synchronize_jira, params: { company_id: 'foo', project_id: project, id: jira_config }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { put :synchronize_jira, params: { company_id: company, project_id: project, id: jira_config }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #edit' do
      let!(:project) { Fabricate :project, customers: [customer], products: [product] }

      it 'renders the SPA template' do
        get :edit, params: { company_id: company, project_id: project, id: 'foo' }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #index' do
      let!(:project) { Fabricate :project, company: company }
      let!(:jira_config) { Fabricate :jira_project_config, project: project }
      let!(:other_jira_config) { Fabricate :jira_project_config, project: project }
      let!(:out_jira_config) { Fabricate :jira_project_config }

      context 'valid parameters' do
        before { get :index, params: { company_id: company, project_id: project } }

        it 'renders the index template' do
          expect(response).to render_template 'spa-build/index'
        end
      end

      context 'invalid parameters' do
        context 'non-existent project' do
          before { get :index, params: { company_id: company, project_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :index, params: { company_id: company, project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
