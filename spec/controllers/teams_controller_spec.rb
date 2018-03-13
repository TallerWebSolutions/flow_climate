# frozen_string_literal: true

RSpec.describe TeamsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #search_for_projects' do
      before { get :search_for_projects, params: { company_id: 'foo', id: 'foo', status_filter: :executing }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #show' do
      let(:team) { Fabricate :team, company: company }
      let(:first_team_member) { Fabricate :team_member, team: team }
      let(:second_team_member) { Fabricate :team_member, team: team }
      let(:third_team_member) { Fabricate :team_member, team: team }

      let!(:first_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, username: 'zzz' }
      let!(:second_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, username: 'aaa' }
      let!(:third_pipefy_team_config) { Fabricate :pipefy_team_config, username: 'aaa' }

      let(:customer) { Fabricate :customer, company: company }

      let!(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.today, end_date: Time.zone.now }
      let!(:second_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 1.month.from_now, end_date: 1.month.from_now }

      let!(:first_result) { Fabricate :project_result, project: first_project, team: team }
      let!(:second_result) { Fabricate :project_result, project: second_project, team: team, result_date: 1.month.from_now }

      context 'passing a valid ID' do
        context 'having data' do
          before { get :show, params: { company_id: company, id: team.id } }
          it 'assigns the instance variables and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:team)).to eq team
            expect(assigns(:report_data)).to be_a ReportData
            expect(assigns(:team_projects)).to eq [second_project, first_project]
            expect(assigns(:strategic_report_data).array_of_months).to eq [[Time.zone.today.month, Time.zone.today.year], [1.month.from_now.to_date.month, 1.month.from_now.to_date.year]]
            expect(assigns(:strategic_report_data).active_projects_count_data).to eq [1, 1]
            expect(assigns(:pipefy_team_configs)).to eq [second_pipefy_team_config, first_pipefy_team_config]
          end
        end
        context 'having no data' do
          let(:other_company) { Fabricate :company, users: [user] }
          let(:empty_team) { Fabricate :team, company: other_company }

          before { get :show, params: { company_id: other_company, id: empty_team } }
          it 'assigns the empty instance variables and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq other_company
            expect(assigns(:team)).to eq empty_team
            expect(assigns(:report_data)).to be_nil
            expect(assigns(:team_projects)).to eq []
          end
        end
      end
      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', id: team } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent team' do
          before { get :show, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { company_id: company, id: team } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }
        it 'instantiates a new Team and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:team)).to be_a_new Team
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
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, team: { name: 'foo' } } }
        it 'creates the new team and redirects to its show' do
          expect(Team.last.name).to eq 'foo'
          expect(response).to redirect_to company_team_path(company, Team.last)
        end
      end
      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team: { name: '' } } }
        it 'does not create the team and re-render the template with the errors' do
          expect(Team.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:team).errors.full_messages).to eq ['Nome não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: team } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:team)).to eq team
        end
      end

      context 'invalid' do
        context 'team' do
          before { get :edit, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: team } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, id: team } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: team, team: { name: 'foo' } } }
        it 'updates the team and redirects to company show' do
          expect(Team.last.name).to eq 'foo'
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'team parameters' do
          before { put :update, params: { company_id: company, id: team, team: { name: nil } } }
          it 'does not update the team and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:team).errors.full_messages).to eq ['Nome não pode ficar em branco']
          end
        end
        context 'non-existent team' do
          before { put :update, params: { company_id: company, id: 'foo', team: { name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, id: team, team: { name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe '#search_for_projects' do
      let(:customer) { Fabricate :customer, company: company }
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 10.days.from_now }
          let!(:first_project_result) { Fabricate :project_result, project: first_project, team: team }
          let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 50.days.from_now }
          let!(:second_project_result) { Fabricate :project_result, project: second_project, team: team }
          let!(:third_project) { Fabricate :project, customer: customer, product: product, status: :waiting, end_date: 15.days.from_now }
          let!(:third_project_result) { Fabricate :project_result, project: third_project, team: team }
          let!(:other_team_project) { Fabricate :project, status: :executing }
          let!(:other_team_project_result) { Fabricate :project_result, project: other_team_project, team: other_team }

          context 'and passing a status filter' do
            before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :executing }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, first_project]
            end
          end
          context 'and passing no status filter' do
            before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :all }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, third_project, first_project]
            end
          end
        end
        context 'having no data' do
          let!(:other_company_project) { Fabricate :project, status: :executing }

          before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :executing }, xhr: true }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template 'projects/projects_search.js.erb'
            expect(assigns(:projects)).to eq []
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :search_for_projects, params: { company_id: 'foo', id: team, status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'team' do
          before { get :search_for_projects, params: { company_id: company, id: 'foo', status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
