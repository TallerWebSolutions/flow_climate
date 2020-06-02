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
      before { get :replenishing_input, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #team_projects_tab' do
      before { get :team_projects_tab, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #dashboard_search' do
      before { get :dashboard_search, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #demands_tab' do
      before { get :demands_tab, params: { company_id: 'bar', id: 'foo' } }

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

    after { travel_back }

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
    let(:product) { Fabricate :product, customer: customer }

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

      let!(:first_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member }
      let!(:second_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: second_team_member }
      let!(:third_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: third_team_member }

      let!(:fourth_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: first_team_member }
      let!(:fifth_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: second_team_member }
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
            expect(assigns(:projects)).to eq [third_project, fourth_project, second_project, first_project]

            expect(assigns(:work_item_flow_information)).to be_a Flow::WorkItemFlowInformations
            expect(assigns(:statistics_flow_information)).to be_a Flow::StatisticsFlowInformations
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
            expect(assigns(:projects)).to eq []
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
          expect(response).to redirect_to company_team_path(company, team)
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
        include_context 'demands to filters'

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
          expect(response).to render_template 'teams/replenishing_input'
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'with valid parameters' do
        context 'with no dependencies' do
          let!(:other_team) { Fabricate :team, company: company }

          it 'destroys the team and updates the view' do
            team_name = other_team.name
            delete :destroy, params: { company_id: company, id: other_team }, xhr: true
            expect(Team.all).to eq [team]
            expect(response).to render_template 'teams/destroy'
            expect(flash[:notice]).to eq I18n.t('teams.destroy.success', team_name: team_name)
          end
        end

        context 'with dependencies' do
          let!(:other_team) { Fabricate :team, company: company }
          let!(:project) { Fabricate :project, company: company, team: other_team }

          it 'does not destroy the team and updates the view informing the error' do
            delete :destroy, params: { company_id: company, id: other_team }, xhr: true
            expect(Team.all).to match_array [team, other_team]
            expect(response).to render_template 'teams/destroy'
            expect(flash[:error]).to eq 'Não é possível excluir o registro pois existem projetos dependentes'
          end
        end
      end

      context 'with invalid' do
        context 'company' do
          context 'non-existent' do
            before { delete :destroy, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end
        end

        context 'not_permitted' do
          let!(:team) { Fabricate :team }

          before { delete :destroy, params: { company_id: 'foo', id: team } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #team_projects_tab' do
      let!(:first_team) { Fabricate :team, company: company }
      let!(:second_team) { Fabricate :team, company: company }

      context 'with valid parameters' do
        context 'having data' do
          include_context 'demands to filters'

          let!(:first_project_consolidation) { Fabricate :project_consolidation, consolidation_date: 2.weeks.ago, project: first_project }
          let!(:second_project_consolidation) { Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: first_project }

          let!(:third_project_consolidation) { Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: second_project }

          it 'creates the objects and renders the tab' do
            get :team_projects_tab, params: { company_id: company, id: team }, xhr: true

            expect(response).to render_template 'teams/team_projects_tab'
            expect(assigns(:x_axis_index)).to eq [1, 2, 3, 4, 5]
            expect(assigns(:projects_lead_time_in_time)).to match_array [{ data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0], name: first_project.name }, { data: [0, 0, 0, 0, 0, 0, 0, 0, 0.0], name: second_project.name }]
            expect(assigns(:projects_risk_in_time)).to match_array [{ data: [87.5, 87.5], name: first_project.name }, { data: [37.5], name: second_project.name }]
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
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

    describe 'GET #dashboard_search' do
      context 'with data' do
        include_context 'demands to filters'

        context 'with valid parameters' do
          context 'with no search parameters' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [first_demand, second_demand, fifth_demand, third_demand, fourth_demand]
              expect(assigns(:paged_demands_searched)).to eq [first_demand, second_demand, fifth_demand, third_demand, fourth_demand]
            end
          end

          context 'with search by start and end dates' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, start_date: 1.day.ago, end_date: Time.zone.now }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [first_demand, second_demand, fifth_demand, third_demand]
            end
          end

          context 'with search by demand status' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, flow_status: 'delivered' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands.map(&:external_id)).to eq [first_demand, second_demand, fifth_demand, third_demand].map(&:external_id)
            end
          end

          context 'with search by demand type bug' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_type: 'bug' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [second_demand]
            end
          end

          context 'with search by demand type feature' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_type: 'feature' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [first_demand]
            end
          end

          context 'with search by demand type chore' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_type: 'chore' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [fifth_demand]
            end
          end

          context 'with search by demand type performance_improvement' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_type: 'performance_improvement' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [third_demand]
            end
          end

          context 'with search by demand type ui' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_type: 'ui' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [fourth_demand]
            end
          end

          context 'with search by invalid demand type' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_type: 'foo' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [first_demand, second_demand, fifth_demand, third_demand, fourth_demand]
            end
          end

          context 'with search by class of service standard' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_class_of_service: 'standard' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [first_demand, second_demand]
            end
          end

          context 'with search by class of service expedite' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_class_of_service: 'expedite' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [third_demand]
            end
          end

          context 'with search by class of service fixed_date' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_class_of_service: 'fixed_date' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [fourth_demand]
            end
          end

          context 'with search by class of service intangible' do
            it 'search the informations and renders the template' do
              get :dashboard_search, params: { company_id: company, id: team, demand_class_of_service: 'intangible' }, xhr: true

              expect(response).to render_template 'teams/dashboards/dashboard_search'
              expect(assigns(:work_item_flow_information).demands).to eq [fifth_demand]
            end
          end
        end

        context 'with invalid' do
          context 'team' do
            before { get :dashboard_search, params: { company_id: company, id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'company' do
            context 'no existent' do
              before { get :dashboard_search, params: { company_id: 'foo', id: team } }

              it { expect(response).to have_http_status :not_found }
            end

            context 'not permitted' do
              let(:company) { Fabricate :company, users: [] }

              before { get :dashboard_search, params: { company_id: company, id: team } }

              it { expect(response).to have_http_status :not_found }
            end
          end
        end
      end
    end

    describe 'GET #demands_tab' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'demands to filters'

          it 'creates the objects and renders the tab' do
            get :demands_tab, params: { company_id: company, id: team, demands_ids: team.demands.map(&:id).join(',') }, xhr: true

            expect(response).to render_template 'teams/demands_tab'
            expect(assigns(:demands)).to eq [first_demand, second_demand, fifth_demand, third_demand, fourth_demand]
            expect(assigns(:paged_demands)).to eq [first_demand, second_demand, fifth_demand, third_demand, fourth_demand]
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          get :demands_tab, params: { company_id: company, id: team }, xhr: true

          expect(response).to render_template 'teams/demands_tab'
          expect(assigns(:demands)).to eq []
          expect(assigns(:paged_demands)).to eq []
        end
      end

      context 'with invalid' do
        context 'team' do
          before { get :demands_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'no existent' do
            before { get :demands_tab, params: { company_id: 'foo', id: team } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :demands_tab, params: { company_id: company, id: team } }

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
            get :dashboard_page_five, params: { company_id: company, id: team }, xhr: true

            expect(response).to render_template 'teams/dashboards/dashboard_page_five'
            expect(response).to render_template 'teams/dashboards/_dashboard_tab_page_five'
            expect(assigns(:x_axis_index)).to eq [1]
            expect(assigns(:memberships_lead_time_in_time)).to match_array [{ data: [0.8], name: first_team_member.name }, { data: [0, 5.800000000000001], name: second_team_member.name }]
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
  end
end
