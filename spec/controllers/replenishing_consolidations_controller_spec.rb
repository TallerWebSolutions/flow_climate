# frozen_string_literal: true

RSpec.describe ReplenishingConsolidationsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo', team_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #refresh_cache' do
      before { put :refresh_cache, params: { company_id: 'foo', team_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }

    before { sign_in user }

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let(:team) { Fabricate :team, company: company }
      let(:project) { Fabricate :project, company: company, team: team, status: :executing }
      let(:other_project) { Fabricate :project, company: company, team: team, status: :executing }
      let(:other_team_project) { Fabricate :project, company: company, status: :executing }

      context 'with valid values' do
        context 'with data' do
          it 'assigns the instance variable and renders the template' do
            consolidation = Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today
            Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.day.ago
            other_project_consolidation = Fabricate :replenishing_consolidation, project: other_project, consolidation_date: 1.day.ago

            Fabricate :replenishing_consolidation, project: other_team_project, consolidation_date: 1.day.ago

            get :index, params: { company_id: company, team_id: team }

            expect(response).to render_template 'spa-build/index'
            expect(assigns(:replenishing_consolidations)).to match_array [other_project_consolidation, consolidation]
          end
        end

        context 'with no data' do
          it 'assigns an empty instance variable and renders the template' do
            Fabricate :replenishing_consolidation, project: other_team_project, consolidation_date: 1.day.ago

            get :index, params: { company_id: company, team_id: team }

            expect(response).to render_template 'spa-build/index'
            expect(assigns(:replenishing_consolidations)).to eq []
          end
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :index, params: { company_id: company, team_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { get :index, params: { company_id: 'foo', team_id: team } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not allowed company' do
          let(:other_company) { Fabricate :company }

          before { get :index, params: { company_id: other_company, team_id: team } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not allowed team' do
          let(:other_team) { Fabricate :team }

          before { get :index, params: { company_id: company, team_id: other_team } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #refresh_cache' do
      let(:company) { Fabricate :company, users: [user] }
      let(:team) { Fabricate :team, company: company }
      let(:project) { Fabricate :project, company: company, team: team, status: :executing }
      let(:other_project) { Fabricate :project, company: company, team: team, status: :executing }
      let(:other_team_project) { Fabricate :project, company: company, status: :executing }

      context 'with valid values' do
        it 'assigns the instance variable and renders the template' do
          expect do
            put :refresh_cache, params: { company_id: company, team_id: team }, xhr: true
          end.to enqueue_job(Consolidations::ReplenishingConsolidationJob)

          expect(flash[:notice]).to eq I18n.t('general.enqueued')
          expect(response).to render_template 'replenishing_consolidations/refresh_cache'
        end
      end

      context 'with invalid' do
        context 'team' do
          before { put :refresh_cache, params: { company_id: company, team_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { put :refresh_cache, params: { company_id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not allowed company' do
          let(:other_company) { Fabricate :company }

          before { put :refresh_cache, params: { company_id: other_company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not allowed team' do
          let(:other_team) { Fabricate :team }

          before { put :refresh_cache, params: { company_id: company, team_id: other_team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
