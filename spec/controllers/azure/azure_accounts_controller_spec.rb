# frozen_string_literal: true

RSpec.describe Azure::AzureAccountsController, type: :controller do
  context 'unauthenticated' do
    describe 'POST #synchronize_azure' do
      before { post :synchronize_azure, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'POST #synchronize_azure' do
      let(:azure_account) { Fabricate :azure_account, company: company }

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
  end
end
