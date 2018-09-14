# frozen_string_literal: true

RSpec.describe Jira::ProjectJiraConfigsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', project_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', project_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customer: customer }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project } }
        it 'instantiates a new Customer and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:project_jira_config)).to be_a_new Jira::ProjectJiraConfig
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
      let!(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, project_jira_config: { team_id: team.id, jira_account_domain: 'foo', jira_project_key: 'bar', fix_version_name: 'xpto' } } }
        it 'creates the new customer and redirects to its show' do
          created_config = Jira::ProjectJiraConfig.last
          expect(created_config.team).to eq team
          expect(created_config.jira_account_domain).to eq 'foo'
          expect(created_config.jira_project_key).to eq 'bar'
          expect(created_config.fix_version_name).to eq 'xpto'

          expect(response).to redirect_to company_project_path(company, project)
        end
      end
      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, project_jira_config: { name: '' } } }
          it 'does not create the customer and re-render the template with the errors' do
            expect(Jira::ProjectJiraConfig.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:project_jira_config).errors.full_messages).to eq ['Time não pode ficar em branco', 'Domínio da Conta no Jira não pode ficar em branco', 'Chave do Projeto no Jira não pode ficar em branco']
          end
        end

        context 'non-existent project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_jira_config: { name: '' } } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_jira_config: { name: '' } } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { post :create, params: { company_id: company, project_id: project, project_jira_config: { name: '' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
