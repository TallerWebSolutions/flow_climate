# frozen_string_literal: true

RSpec.describe Jira::JiraAccountsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }

        it 'instantiates a new project jira config and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:jira_account)).to be_a_new Jira::JiraAccount
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
      let!(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, jira_jira_account: { base_uri: 'foo.bar', username: 'foo', customer_domain: 'bar', api_token: 'xptobar' } } }

        it 'creates the new jira account' do
          created_account = Jira::JiraAccount.last
          expect(created_account.base_uri).to eq 'foo.bar'
          expect(created_account.username).to eq 'foo'
          expect(created_account.customer_domain).to eq 'bar'
          expect(created_account.encrypted_api_token).not_to be_empty

          expect(flash[:notice]).to eq I18n.t('jira_accounts.create.success')
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, jira_jira_account: { name: '' } } }

          it 'does not create the project jira config' do
            expect(Jira::JiraAccount.last).to be_nil
            expect(response).to render_template :new
            expect(flash[:error]).to eq I18n.t('jira_accounts.create.failed')
            expect(assigns(:jira_account).errors.full_messages).to eq ['Nome de usuário não pode ficar em branco', 'Token da API não pode ficar em branco', 'URI base não pode ficar em branco', 'Domínio do Usuário não pode ficar em branco']
          end
        end

        context 'non-existent company' do
          before { post :create, params: { company_id: 'foo', jira_jira_account: { name: '' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { post :create, params: { company_id: company, jira_jira_account: { name: '' } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:first_account) { Fabricate :jira_account, company: company, created_at: 1.day.ago }
      let!(:second_account) { Fabricate :jira_account, company: company, created_at: 2.days.ago }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, id: first_account }, xhr: true }

        it 'deletes the jira config' do
          expect(response).to render_template 'jira/jira_accounts/destroy'
          expect(assigns(:jira_accounts_list)).to eq [second_account]
          expect(Jira::JiraAccount.last).to eq second_account
        end
      end

      context 'invalid parameters' do
        context 'non-existent jira_account' do
          before { delete :destroy, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: first_account }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, id: first_account }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:jira_account) { Fabricate :jira_account, company: company }
      let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }
      let!(:other_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }

      context 'valid parameters' do
        it 'assigns the instance variable and renders the template' do
          get :show, params: { company_id: company, id: jira_account }
          expect(response).to render_template :show
          expect(assigns(:jira_account)).to eq jira_account
          expect(assigns(:jira_custom_field_mappings)).to eq [jira_custom_field_mapping, other_jira_custom_field_mapping]
        end
      end

      context 'invalid' do
        context 'jira_account' do
          context 'not found' do
            before { get :show, params: { company_id: company, id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_account) { Fabricate :jira_account }

            before { get :show, params: { company_id: company, id: not_permitted_account }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end

        context 'company' do
          context 'not found' do
            before { get :show, params: { company_id: 'foo', id: jira_account }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }
            let(:jira_account) { Fabricate :jira_account, company: company }

            before { get :show, params: { company_id: not_permitted_company, id: jira_account }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
