# frozen_string_literal: true

RSpec.describe ReplenishingConsolidationsController do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo', team_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }

    before { sign_in user }

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let(:team) { Fabricate :team, company: company }

      context 'with valid values' do
        context 'with data' do
          it 'renders the spa template' do
            get :index, params: { company_id: company, team_id: team }

            expect(response).to render_template 'spa-build/index'
          end
        end
      end

      context 'with invalid' do
        context 'company' do
          before { get :index, params: { company_id: 'foo', team_id: team } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not allowed company' do
          let(:other_company) { Fabricate :company }

          before { get :index, params: { company_id: other_company, team_id: team } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
