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

    describe 'GET #replenishing_input' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    after { travel_back }

    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }
    let(:first_team_member) { Fabricate :team_member, team: team }
    let(:second_team_member) { Fabricate :team_member, team: team }
    let(:third_team_member) { Fabricate :team_member, team: team }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }

    describe 'GET #show' do
      let!(:first_project) { Fabricate :project, customers: [customer], team: team, status: :executing, start_date: 4.months.ago, end_date: Time.zone.today }
      let!(:second_project) { Fabricate :project, customers: [customer], team: team, status: :maintenance, start_date: 2.months.ago, end_date: 34.days.from_now }
      let!(:third_project) { Fabricate :project, customers: [customer], team: team, status: :waiting, start_date: 1.month.ago, end_date: 2.months.from_now }
      let!(:fourth_project) { Fabricate :project, customers: [customer], team: team, product: product, status: :cancelled, start_date: 35.days.from_now, end_date: 37.days.from_now }
      let!(:fifth_project) { Fabricate :project, customers: [customer], team: team, product: product, status: :finished, start_date: 38.days.from_now, end_date: 39.days.from_now }

      let(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline }
      let(:second_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :backlog_growth_rate }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: first_project, alert_color: :green, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: first_project, alert_color: :red, created_at: 1.hour.ago }

      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.months.ago, end_date: 2.months.ago, effort_upstream: 200, effort_downstream: 150 }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 2.months.ago, end_date: 1.month.ago, leadtime: 2003, effort_upstream: 200, effort_downstream: 150 }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago, leadtime: 2203, effort_upstream: 200, effort_downstream: 150 }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.today, leadtime: 3003, effort_upstream: 200, effort_downstream: 150 }

      context 'passing a valid ID' do
        context 'having data' do
          it 'assigns the instance variables and renders the template' do
            expect_any_instance_of(AuthenticatedController).to(receive(:user_gold_check).once.and_return(true))
            get :show, params: { company_id: company, id: team }

            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:team)).to eq team
            expect(assigns(:team_projects)).to eq [third_project, fifth_project, fourth_project, second_project, first_project]
            expect(assigns(:active_team_projects)).to eq [third_project, second_project, first_project]
            expect(assigns(:projects_risk_chart_data).backlog_risk_alert_data).to eq [{ name: 'Vermelho', y: 1, color: '#FB283D' }]
            expect(assigns(:projects_risk_chart_data).money_risk_alert_data).to eq [{ name: 'Verde', y: 1, color: '#179A02' }]
          end
        end

        context 'having no data' do
          let(:other_company) { Fabricate :company, users: [user] }
          let(:empty_team) { Fabricate :team, company: other_company }

          it 'assigns the empty instance variables and renders the template' do
            expect_any_instance_of(AuthenticatedController).to(receive(:user_gold_check).once.and_return(true))
            get :show, params: { company_id: other_company, id: empty_team }
            expect(response).to render_template :show
            expect(assigns(:company)).to eq other_company
            expect(assigns(:team)).to eq empty_team
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
        it 'instantiates a new Team and renders the template' do
          get :new, params: { company_id: company }
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
        it 'creates the new team and redirects to its show' do
          post :create, params: { company_id: company, team: { name: 'foo', max_work_in_progress: 12 } }
          expect(Team.last.name).to eq 'foo'
          expect(Team.last.reload.max_work_in_progress).to eq 12
          expect(response).to redirect_to company_team_path(company, Team.last)
        end
      end

      context 'passing invalid parameters' do
        it 'does not create the team and re-render the template with the errors' do
          post :create, params: { company_id: company, team: { name: '' } }
          expect(response).to render_template :new
          expect(assigns(:team).errors.full_messages).to eq ['Nome não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }

      context 'valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :edit, params: { company_id: company, id: team }
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
        it 'updates the team and redirects to company show' do
          put :update, params: { company_id: company, id: team, team: { name: 'foo', max_work_in_progress: 12 } }
          expect(team.reload.name).to eq 'foo'
          expect(team.reload.max_work_in_progress).to eq 12
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'team parameters' do
          it 'does not update the team and re-render the template with the errors' do
            put :update, params: { company_id: company, id: team, team: { name: nil } }

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

    describe 'GET #replenishing_input' do
      context 'having data' do
        let!(:first_project) { Fabricate :project, customers: [customer], team: team, name: 'first_project', status: :executing, start_date: 4.months.ago, end_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, customers: [customer], team: team, name: 'second_project', status: :executing, start_date: 2.months.ago, end_date: 3.days.from_now }
        let!(:third_project) { Fabricate :project, customers: [customer], team: team, name: 'third_project', status: :executing, start_date: 1.month.ago, end_date: 1.week.from_now }

        it 'returns the data and redirects' do
          get :replenishing_input, params: { company_id: company, id: team }, xhr: true

          expect(assigns(:replenishing_data)).to be_a ReplenishingData
        end
      end

      context 'having no data' do
        before { get :replenishing_input, params: { company_id: company, id: team }, xhr: true }

        it 'returns an empty array and redirects' do
          replenishing_data = assigns(:replenishing_data).project_data_to_replenish
          expect(replenishing_data).to eq []
          expect(response).to render_template 'teams/replenishing_input.js.erb'
        end
      end
    end
  end
end
