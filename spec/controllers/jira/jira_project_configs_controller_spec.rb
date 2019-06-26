# frozen_string_literal: true

RSpec.describe Jira::JiraProjectConfigsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', project_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', project_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', project_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customers: [customer] }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project }, xhr: true }

        it 'instantiates a new project jira config and renders the template' do
          expect(response).to render_template 'jira/jira_project_configs/new'
          expect(assigns(:jira_project_config)).to be_a_new Jira::JiraProjectConfig
        end
      end

      context 'invalid parameters' do
        context 'non-existent project' do
          before { get :new, params: { company_id: company, project_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', project_id: project }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, project_id: project }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { jira_project_key: 'bar', fix_version_name: 'xpto' } }, xhr: true }

        it 'creates the new project jira config' do
          created_config = Jira::JiraProjectConfig.last
          expect(created_config.fix_version_name).to eq 'xpto'

          expect(response).to render_template 'jira/jira_project_configs/create'
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { name: '' } }, xhr: true }

          it 'does not create the project jira config' do
            expect(Jira::JiraProjectConfig.last).to be_nil
            expect(response).to render_template 'jira/jira_project_configs/create'
            expect(assigns(:jira_project_config).errors.full_messages).to eq ['Fix Version ou Label no Jira não pode ficar em branco']
          end
        end

        context 'breaking unique index' do
          let!(:jira_project_config) { Fabricate :jira_project_config, project: project, fix_version_name: 'xpto' }

          before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { jira_project_key: 'bar', fix_version_name: 'xpto' } }, xhr: true }

          it 'does not create the project jira config' do
            expect(Jira::JiraProjectConfig.count).to eq 1
            expect(response).to render_template 'jira/jira_project_configs/create'
            expect(assigns(:jira_project_config).errors_on(:fix_version_name)).to eq [I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message')]
            expect(flash[:error]).to eq I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message')
          end
        end

        context 'non-existent project' do
          before { post :create, params: { company_id: company, project_id: 'foo', jira_jira_project_config: { name: '' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { post :create, params: { company_id: 'foo', project_id: project, jira_jira_project_config: { name: '' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { post :create, params: { company_id: company, project_id: project, jira_jira_project_config: { name: '' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:jira_project_config) { Fabricate :jira_project_config, project: project }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, project_id: project, id: jira_project_config }, xhr: true }

        it 'deletes the jira config' do
          expect(response).to render_template 'jira/jira_project_configs/destroy'
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
  end
end
