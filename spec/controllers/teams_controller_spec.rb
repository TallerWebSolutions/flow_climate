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

    describe 'GET #edit' do
      before { get :new, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #team_projects_tab' do
      before { get :team_projects_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #dashboard_tab' do
      before { get :dashboard_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #dashboard_page_two' do
      before { get :dashboard_page_two, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #dashboard_page_three' do
      before { get :dashboard_page_three, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #dashboard_page_four' do
      before { get :dashboard_page_four, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    let(:first_team_member) { Fabricate :team_member, company: company }
    let(:second_team_member) { Fabricate :team_member, company: company }
    let(:third_team_member) { Fabricate :team_member, company: company }

    let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, start_date: 3.weeks.ago, end_date: nil, member_role: :developer }
    let!(:second_membership) { Fabricate :membership, team: team, team_member: second_team_member, start_date: 1.week.ago, end_date: nil, member_role: :developer }
    let!(:third_membership) { Fabricate :membership, team: team, team_member: third_team_member, start_date: 1.week.ago, end_date: nil, member_role: :manager }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

    shared_context 'demands to filters' do
      let!(:first_project) { Fabricate :project, products: [product], customers: [customer], team: team, status: :executing, start_date: 4.months.ago, end_date: Time.zone.today }
      let!(:second_project) { Fabricate :project, products: [product], customers: [customer], team: team, status: :maintenance, start_date: 2.months.ago, end_date: 34.days.from_now }
      let!(:third_project) { Fabricate :project, products: [product], customers: [customer], team: team, status: :waiting, start_date: 1.month.ago, end_date: 2.months.from_now }
      let!(:fourth_project) { Fabricate :project, products: [product], customers: [customer], team: team, status: :cancelled, start_date: 35.days.from_now, end_date: 37.days.from_now }

      let!(:first_demand) { Fabricate :demand, product: product, team: team, project: first_project, demand_type: :feature, class_of_service: :standard, external_id: 'first_demand', created_date: 4.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago }
      let!(:second_demand) { Fabricate :demand, product: product, team: team, project: second_project, demand_type: :bug, class_of_service: :standard, external_id: 'second_demand', created_date: 1.day.ago, commitment_date: 1.day.ago, end_date: 1.day.ago }
      let!(:third_demand) { Fabricate :demand, product: product, team: team, project: third_project, demand_type: :performance_improvement, class_of_service: :expedite, external_id: 'third_demand', created_date: 7.days.ago, commitment_date: 7.days.ago, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, product: product, team: team, project: first_project, demand_type: :ui, class_of_service: :fixed_date, external_id: 'fourth_demand', created_date: 7.days.ago, commitment_date: 7.days.ago, end_date: nil }
      let!(:fifth_demand) { Fabricate :demand, product: product, team: team, project: fourth_project, demand_type: :chore, class_of_service: :intangible, external_id: 'fifth_demand', end_date: 3.hours.ago }

      let!(:first_assignment) { Fabricate :item_assignment, demand: first_demand, membership: first_membership }
      let!(:second_assignment) { Fabricate :item_assignment, demand: first_demand, membership: second_membership }
      let!(:third_assignment) { Fabricate :item_assignment, demand: first_demand, membership: third_membership }

      let!(:fourth_assignment) { Fabricate :item_assignment, demand: second_demand, membership: first_membership }
      let!(:fifth_assignment) { Fabricate :item_assignment, demand: third_demand, membership: second_membership }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: company } }

      it { expect(response).to render_template 'spa-build/index' }
    end

    describe 'GET #show' do
      include_context 'demands to filters'

      context 'passing a valid ID' do
        context 'having data' do
          it 'assigns the instance variables and renders the template' do
            expect_any_instance_of(AuthenticatedController).to(receive(:user_gold_check).once.and_return(true))
            get :show, params: { company_id: company, id: team }

            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:team)).to eq team

            expect(assigns(:work_item_flow_information)).to be_a Flow::WorkItemFlowInformation
            expect(assigns(:statistics_flow_information)).to be_a Flow::StatisticsFlowInformation
            expect(assigns(:average_speed)).to eq 1.3333333333333333
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
          end
        end
      end

      context 'invalid' do
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

        context 'a different company' do
          let(:other_company) { Fabricate :company, users: [user] }
          let!(:team) { Fabricate :team, company: company }

          before { get :show, params: { company_id: other_company, id: team } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      context 'valid parameters' do
        it 'renders the team template' do
          get :edit, params: { company_id: company, id: team }
          expect(response).to render_template 'spa-build/index'
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        it 'renders the team template' do
          get :new, params: { company_id: company }
          expect(response).to render_template 'spa-build/index'
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

    describe 'GET #team_projects_tab' do
      let!(:first_team) { Fabricate :team, company: company }
      let!(:second_team) { Fabricate :team, company: company }

      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            Fabricate :project_consolidation, consolidation_date: 2.weeks.ago, project: first_project, operational_risk: 0.875, team_based_operational_risk: 0.2, last_data_in_week: true
            Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: first_project, operational_risk: 0.875, team_based_operational_risk: 0.1, last_data_in_week: true
            Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: second_project, operational_risk: 0.375, team_based_operational_risk: 0.75, last_data_in_week: true
            Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: second_project, operational_risk: 0.375, team_based_operational_risk: 0.32, last_data_in_week: false

            expect_any_instance_of(Highchart::ProjectsChartAdapter).to(receive(:hours_per_project_in_period)).once.and_return({ x_axis: %(a b), data: { 'bla' => [2, 3] } })
            get :team_projects_tab, params: { company_id: company, id: team }, xhr: true

            expect(response).to render_template 'teams/team_projects_tab'
            expect(assigns(:x_axis_index)).to eq [1, 2, 3, 4, 5]
            expect(assigns(:projects_lead_time_in_time)).to match_array [{ data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0], name: first_project.name }, { data: [0, 0, 0, 0, 0, 0, 0, 0, 0.0], name: second_project.name }]
            expect(assigns(:projects_risk_in_time)).to match_array [{ data: [87.5, 87.5], name: first_project.name }, { data: [37.5], name: second_project.name }]
            expect(assigns(:projects_risk_in_time_team_based)).to match_array [{ data: [20, 10], name: first_project.name }, { data: [75], name: second_project.name }]
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          expect_any_instance_of(Highchart::ProjectsChartAdapter).to(receive(:hours_per_project_in_period)).once.and_return({})
          get :team_projects_tab, params: { company_id: company, id: first_team }, xhr: true

          expect(assigns(:x_axis_index)).to eq []
          expect(assigns(:projects_lead_time_in_time)).to eq []
          expect(assigns(:projects_risk_in_time)).to eq []
          expect(response).to render_template 'teams/team_projects_tab'
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :team_projects_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :team_projects_tab, params: { company_id: 'foo', id: first_team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :team_projects_tab, params: { company_id: company, id: first_team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #dashboard_tab' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            get :dashboard_tab, params: { company_id: company, id: team }, xhr: true

            expect(response).to render_template 'teams/dashboards/dashboard_tab'
          end
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :dashboard_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :dashboard_tab, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :dashboard_tab, params: { company_id: company, id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #dashboard_page_two' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            get :dashboard_page_two, params: { company_id: company, id: team }, xhr: true

            expect(assigns(:team_chart_data)).to be_a Highchart::TeamChartsAdapter

            expect(response).to render_template 'teams/dashboards/dashboard_page_two'
          end
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :dashboard_page_two, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :dashboard_page_two, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :dashboard_page_two, params: { company_id: company, id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #dashboard_page_three' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            get :dashboard_page_three, params: { company_id: company, id: team }, xhr: true

            expect(assigns(:demands_chart_adapter)).to be_a Highchart::DemandsChartsAdapter

            expect(response).to render_template 'teams/dashboards/dashboard_page_three'
          end
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :dashboard_page_three, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :dashboard_page_three, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :dashboard_page_three, params: { company_id: company, id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #dashboard_page_four' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            get :dashboard_page_four, params: { company_id: company, id: team }, xhr: true

            expect(assigns(:strategic_chart_data)).to be_a Highchart::StrategicChartsAdapter

            expect(response).to render_template 'teams/dashboards/dashboard_page_four'
            expect(response).to render_template 'charts/_strategic_charts'
          end
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :dashboard_page_four, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :dashboard_page_four, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :dashboard_page_four, params: { company_id: company, id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #dashboard_page_five' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            allow(Membership).to(receive(:developer).and_return(Membership.all))

            allow_any_instance_of(Membership).to(receive(:demands).and_return(Demand.all))

            get :dashboard_page_five, params: { company_id: company, id: team }, xhr: true

            expect(response).to render_template 'teams/dashboards/dashboard_page_five'
            expect(response).to render_template 'teams/dashboards/_dashboard_tab_page_five'
            expect(assigns(:x_axis_index)).to eq [1]
            expect(assigns(:memberships_lead_time_in_time)).to match_array [{ data: [0, 4.6000000000000005], name: first_team_member.name }, { data: [0, 4.6000000000000005], name: second_team_member.name }, { data: [0, 4.6000000000000005], name: third_team_member.name }]
          end
        end
      end

      context 'with no data' do
        let!(:empty_team) { Fabricate :team, company: company }
        let(:empty_team_member) { Fabricate :team_member, company: company }
        let!(:empty_membership) { Fabricate :membership, team: empty_team, team_member: empty_team_member, start_date: 3.weeks.ago, end_date: nil, member_role: :developer }

        it 'render the template with empty data' do
          get :dashboard_page_five, params: { company_id: company, id: empty_team }, xhr: true

          expect(assigns(:x_axis_index)).to eq [1, 2]
          expect(assigns(:memberships_lead_time_in_time)).to eq [{ data: [], name: empty_team_member.name }]
          expect(response).to render_template 'teams/dashboards/dashboard_page_five'
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :dashboard_page_five, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :dashboard_page_five, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :dashboard_page_five, params: { company_id: company, id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #update_cache' do
      let(:team) { Fabricate :team, company: company }

      context 'with no consolidations' do
        it 'enqueues the cache update for all customer time' do
          Fabricate :demand, team: team, created_date: 4.days.ago, end_date: 4.days.ago
          Fabricate :demand, team: team, created_date: 4.days.ago, end_date: 2.days.ago

          expect(Consolidations::TeamConsolidationJob).to(receive(:perform_later)).exactly(3).times

          patch :update_cache, params: { company_id: company, id: team }

          expect(flash[:notice]).to eq I18n.t('general.enqueued')
          expect(response).to redirect_to company_team_path(company, team)
        end
      end

      context 'with consolidations' do
        it 'enqueues the cache update for the day' do
          Fabricate :demand, team: team, created_date: 4.days.ago, end_date: 4.days.ago
          Fabricate :demand, team: team, created_date: 4.days.ago, end_date: 2.days.ago
          Fabricate :team_consolidation, team: team

          expect(Consolidations::TeamConsolidationJob).to(receive(:perform_later)).exactly(3).times

          patch :update_cache, params: { company_id: company, id: team }

          expect(flash[:notice]).to eq I18n.t('general.enqueued')
          expect(response).to redirect_to company_team_path(company, team)
        end
      end

      context 'with invalid' do
        context 'customer' do
          before { patch :update_cache, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :update_cache, params: { company_id: 'bar', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :update_cache, params: { company_id: company, id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
