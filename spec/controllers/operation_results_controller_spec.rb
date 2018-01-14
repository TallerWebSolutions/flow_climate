# frozen_string_literal: true

RSpec.describe OperationResultsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:result) { Fabricate :operation_result, company: company, result_date: 2.days.ago }
      let!(:other_result) { Fabricate :operation_result, company: company, result_date: Time.zone.today }

      context 'with valid parameters' do
        before { get :index, params: { company_id: company } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :index
          expect(assigns(:operation_results)).to eq [other_result, result]
        end
      end

      context 'with invalid parameters' do
        context 'and invalid company' do
          before { get :index, params: { company_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:operation_result) { Fabricate :operation_result, company: company }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, id: operation_result } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_operation_results_path(company)
          expect(ProjectResult.last).to be_nil
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent operation result' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: operation_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { delete :destroy, params: { company_id: company, id: operation_result } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
