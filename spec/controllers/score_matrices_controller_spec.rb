# frozen_string_literal: true

RSpec.describe ScoreMatricesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }

    before { sign_in user }

    describe 'GET #show' do
      let(:score_matrix) { Fabricate :score_matrix }

      context 'with valid data' do
        before { get :show, params: { id: score_matrix } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :show
          expect(assigns(:score_matrix)).to eq score_matrix
        end
      end

      context 'with invalid' do
        context 'score matrix' do
          before { get :show, params: { id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
