# frozen_string_literal: true

RSpec.describe Azure::AzureAccountsController, type: :controller do
  context 'unauthenticated' do
    describe 'POST #synchronize_azure' do
      before { post :synchronize_azure, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'POST #synchronize_azure' do
      let!(:azure_account) { Fabricate :azure_account, company: company }

      context 'passing valid parameters' do
        it 'calls the job to enqueue the sync' do
          expect(Azure::AzureSyncJob).to receive(:perform_later).once
          post :synchronize_azure, params: { company_id: company }

          expect(response).to redirect_to company_path(company)
          expect(flash[:notice]).to eq I18n.t('general.enqueued')
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { post :synchronize_azure, params: { company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { post :synchronize_azure, params: { company_id: company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #edit' do
      let!(:azure_account) { Fabricate :azure_account, company: company }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: azure_account } }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:azure_account)).to eq azure_account
        end
      end

      context 'invalid' do
        context 'azure_account' do
          let(:company) { Fabricate :company }

          before { get :edit, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: azure_account } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:no_user_company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: no_user_company, id: azure_account } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let!(:azure_account) { Fabricate :azure_account, company: company }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: azure_account, azure_azure_account: { azure_organization: 'foo', username: 'bar', azure_work_item_query: 'query' } } }

        it 'updates the company and redirects to projects index' do
          expect(company.reload.azure_account.reload.azure_organization).to eq 'foo'
          expect(company.reload.azure_account.reload.username).to eq 'bar'
          expect(company.reload.azure_account.reload.azure_work_item_query).to eq 'query'
          expect(response).to redirect_to edit_company_azure_account_path(company, azure_account)
          expect(flash[:notice]).to eq I18n.t('azure_accounts.edit.success')
        end
      end

      context 'passing invalid' do
        context 'azure_account' do
          let(:company) { Fabricate :company }

          before { put :update, params: { company_id: company, id: 'foo', azure_azure_account: { azure_organization: 'foo', username: 'bar', azure_work_item_query: 'query' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'azure account parameters' do
          before { put :update, params: { company_id: company, id: azure_account, azure_azure_account: { azure_organization: '', username: '', azure_work_item_query: '' } } }

          it 'does not update the company and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:azure_account).errors.full_messages).to eq ['Organização não pode ficar em branco', 'Nome de Usuário não pode ficar em branco']
            expect(flash[:error]).to eq I18n.t('azure_accounts.edit.failure')
          end
        end

        context 'non-existent company' do
          before { put :update, params: { company_id: 'foo', id: azure_account, azure_azure_account: { azure_organization: 'foo', username: 'bar', azure_work_item_query: 'query' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, id: azure_account, azure_azure_account: { azure_organization: 'foo', username: 'bar', azure_work_item_query: 'query' } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:azure_account) { Fabricate :azure_account, company: company }

      context 'with valid parameters' do
        it 'assigns the instance variable and renders the template' do
          get :show, params: { company_id: company, id: azure_account }

          expect(assigns(:azure_account)).to eq azure_account
          expect(response).to render_template :show
        end
      end

      context 'company' do
        context 'non-existent' do
          before { get :show, params: { company_id: 'foo', id: azure_account } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted' do
          let(:no_user_company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: no_user_company, id: azure_account } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
