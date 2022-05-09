# frozen_string_literal: true

RSpec.describe ProjectAdditionalHoursController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      it 'redirects to the new session path' do
        get :new, params: { company_id: 'xpto', project_id: 'bar' }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:project) { Fabricate :project, company: company }

    before { sign_in user }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project } }

        it 'renders the SPA template' do
          expect(response).to render_template 'spa-build/index'
          expect(assigns(:company)).to eq company
        end
      end

      context 'invalid parameters' do
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
  end
end
