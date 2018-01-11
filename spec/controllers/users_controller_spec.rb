# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  context 'unauthenticated' do
    describe 'PATCH #change_current_company' do
      before { patch :change_current_company }
      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'PATCH #change_current_company' do
      context 'passing valid parameters' do
        let(:company) { Fabricate :company, users: [user] }
        before { patch :change_current_company, params: { company_id: company } }
        it 'changes the last company id and redirects to show' do
          expect(response).to redirect_to company_path(company)
        end
      end
      context 'passing invalid parameters' do
        context 'and invalid company ID' do
          before { patch :change_current_company, params: { company_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { patch :change_current_company, params: { company_id: company } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
