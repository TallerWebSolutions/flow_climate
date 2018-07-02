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
    describe 'GET #search_demands_to_flow_charts' do
      before { get :search_demands_to_flow_charts, params: { company_id: 'foo', id: 'foo' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
    describe 'GET #search_demands_by_flow_status' do
      before { get :search_demands_by_flow_status, params: { company_id: 'foo', id: 'foo' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
  end

  context 'authenticated' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }
    after { travel_back }

    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }
    let(:first_team_member) { Fabricate :team_member, team: team }
    let(:second_team_member) { Fabricate :team_member, team: team }
    let(:third_team_member) { Fabricate :team_member, team: team }

    let!(:first_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, username: 'zzz' }
    let!(:second_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, username: 'aaa' }
    let!(:third_pipefy_team_config) { Fabricate :pipefy_team_config, username: 'aaa' }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }

    describe 'GET #show' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.today, end_date: Time.zone.today }
      let!(:second_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 32.days.from_now, end_date: 34.days.from_now }
      let!(:third_project) { Fabricate :project, customer: customer, status: :waiting, start_date: 1.month.from_now, end_date: 2.months.from_now }
      let!(:fourth_project) { Fabricate :project, customer: customer, product: product, status: :cancelled, start_date: 35.days.from_now, end_date: 37.days.from_now }
      let!(:fifth_project) { Fabricate :project, customer: customer, product: product, status: :finished, start_date: 38.days.from_now, end_date: 39.days.from_now }

      let!(:project_in_product_team) { Fabricate :project, customer: customer, product: product, status: :waiting, start_date: 40.days.from_now, end_date: 42.days.from_now }

      let!(:first_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
      let!(:second_result) { Fabricate :project_result, project: second_project, team: team, result_date: 33.days.from_now }
      let!(:third_result) { Fabricate :project_result, project: third_project, team: team, result_date: 34.days.from_now }
      let!(:fourth_result) { Fabricate :project_result, project: fourth_project, team: team, result_date: 36.days.from_now }
      let!(:fifth_result) { Fabricate :project_result, project: fifth_project, team: team, result_date: 39.days.from_now }

      let(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline }
      let(:second_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :backlog_growth_rate }
      let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: first_project, alert_color: :green, created_at: Time.zone.now }
      let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: first_project, alert_color: :red, created_at: 1.hour.ago }

      let!(:first_demand) { Fabricate :demand, project_result: first_result, project: first_project, commitment_date: Time.zone.today }
      let!(:second_demand) { Fabricate :demand, project_result: second_result, project: first_project, commitment_date: Time.zone.today, end_date: 2.days.ago, leadtime: 2003 }
      let!(:third_demand) { Fabricate :demand, project_result: third_result, project: first_project, end_date: 1.day.ago, leadtime: 2203 }
      let!(:fourth_demand) { Fabricate :demand, project_result: fourth_result, project: first_project, end_date: Time.zone.today, leadtime: 3003 }

      context 'passing a valid ID' do
        context 'having data' do
          it 'assigns the instance variables and renders the template' do
            get :show, params: { company_id: company, id: team.id }

            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:team)).to eq team
            expect(assigns(:team_projects)).to eq [third_project, project_in_product_team, fifth_project, fourth_project, second_project, first_project]
            expect(assigns(:active_team_projects)).to eq [third_project, project_in_product_team, second_project, first_project]
            expect(assigns(:projects_risk_alert_data).backlog_risk_alert_data).to eq [{ name: 'Vermelho', y: 1, color: '#FB283D' }]
            expect(assigns(:projects_risk_alert_data).money_risk_alert_data).to eq [{ name: 'Verde', y: 1, color: '#179A02' }]
            expect(assigns(:pipefy_team_configs)).to eq [second_pipefy_team_config, first_pipefy_team_config]
            expect(assigns(:demands)).to match_array [first_demand, second_demand, third_demand, fourth_demand]
            expect(assigns(:grouped_delivered_demands)).to be_nil
            expect(assigns(:grouped_customer_demands)).to be_nil
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
          expect(team.reload.name).to eq 'foo'
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

    describe 'GET #search_for_projects' do
      let(:customer) { Fabricate :customer, company: company }
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz', team: team }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
          let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }
          let!(:third_project) { Fabricate :project, customer: customer, product: product, status: :waiting, start_date: Time.zone.yesterday, end_date: 15.days.from_now }
          let!(:project_in_product_team) { Fabricate :project, customer: customer, product: product, status: :waiting, start_date: 2.months.from_now, end_date: 70.days.from_now }

          let!(:first_project_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
          let!(:second_project_result) { Fabricate :project_result, project: second_project, team: team, result_date: Time.zone.today }
          let!(:third_project_result) { Fabricate :project_result, project: third_project, team: team, result_date: Time.zone.today }

          let!(:other_team_project) { Fabricate :project, status: :executing }
          let!(:other_team_project_result) { Fabricate :project_result, project: other_team_project, team: other_team }

          context 'and passing the status filter executing' do
            before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :executing }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, first_project]
            end
          end
          context 'and passing the status filter waiting' do
            before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :waiting }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [project_in_product_team, third_project]
            end
          end
          context 'and passing no status filter' do
            before { get :search_for_projects, params: { company_id: company, id: team, status_filter: :all }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [project_in_product_team, second_project, third_project, first_project]
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

    describe 'GET #search_demands_to_flow_charts' do
      let(:customer) { Fabricate :customer, company: company }
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz', team: team }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
          let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }

          let!(:first_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
          let!(:second_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
          let!(:third_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
          let!(:fourth_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
          let!(:fifth_result) { Fabricate :project_result, project: second_project, team: team, result_date: 1.week.from_now }

          let!(:first_demand) { Fabricate :demand, project_result: first_result, project: first_project, end_date: 3.weeks.ago }
          let!(:second_demand) { Fabricate :demand, project_result: second_result, project: first_project, end_date: 2.weeks.ago }
          let!(:third_demand) { Fabricate :demand, project_result: third_result, project: first_project, end_date: 1.week.ago }
          let!(:fourth_demand) { Fabricate :demand, project_result: fourth_result, project: first_project, end_date: 1.week.ago }
          let!(:fifth_demand) { Fabricate :demand, project_result: fifth_result, project: second_project, end_date: 1.week.ago }

          context 'and passing week and year as parameters' do
            it 'call the repository and renders the JS' do
              expect(DemandsRepository.instance).to(receive(:selected_grouped_by_project_and_week).with([second_project, first_project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).once { [first_demand, second_demand] })
              expect(DemandsRepository.instance).to(receive(:throughput_by_project_and_week).with([second_project, first_project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).once { [third_demand, fourth_demand] })
              get :search_demands_to_flow_charts, params: { company_id: company, id: team, week: 1.week.ago.to_date.cweek, year: 1.week.ago.to_date.cwyear }, xhr: true

              expect(response).to render_template 'teams/flow.js.erb'
              expect(assigns(:flow_report_data)).to be_a Highchart::FlowChartsAdapter
            end
          end
        end
        context 'having no data' do
          it 'renders the JS empty' do
            get :search_demands_to_flow_charts, params: { company_id: company, id: team, week: 1.week.ago.to_date.cweek, year: 1.week.ago.to_date.cwyear }, xhr: true
            expect(response).to render_template 'teams/flow.js.erb'
            expect(assigns(:flow_report_data).projects_demands_selected).to eq({})
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :search_demands_to_flow_charts, params: { company_id: 'foo', id: team }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'team' do
          before { get :search_demands_to_flow_charts, params: { company_id: company, id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :search_demands_to_flow_charts, params: { company_id: company, id: team }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #search_demands_by_flow_status' do
      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz', team: team }
      let(:other_product) { Fabricate :product, customer: other_customer, name: 'aaa', team: team }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
          let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: nil, end_date: nil }
          let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.today, end_date: nil, leadtime: 2003 }
          let!(:third_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago, leadtime: 2203 }
          let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.today, leadtime: 3003 }

          let!(:second_project) { Fabricate :project, customer: other_customer, product: other_product, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }
          let!(:fifth_demand) { Fabricate :demand, project: second_project, commitment_date: nil, end_date: nil }
          let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: Time.zone.today, end_date: nil, leadtime: 43 }
          let!(:seventh_demand) { Fabricate :demand, project: second_project, end_date: 1.day.ago, leadtime: 3432 }
          let!(:eigth_demand) { Fabricate :demand, project: second_project, end_date: Time.zone.today, leadtime: 1223 }

          context 'and passing the flow status all filters false' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'true', grouped_by_month: 'false', grouped_by_customer: 'false', not_started: 'false', wip: 'false', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [first_demand, second_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'true', grouped_by_customer: 'false', not_started: 'false', wip: 'false', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [first_demand, second_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_delivered_demands)[[2018, 4]]).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'false', grouped_by_customer: 'true', not_started: 'false', wip: 'false', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [first_demand, second_demand, third_demand, fourth_demand, fifth_demand, sixth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name]).to match_array [first_demand, second_demand, third_demand, fourth_demand]
                expect(assigns(:grouped_customer_demands)[other_customer.name]).to match_array [fifth_demand, sixth_demand, seventh_demand, eigth_demand]
              end
            end
          end
          context 'and passing the flow status filter not started' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'true', grouped_by_month: 'false', grouped_by_customer: 'false', not_started: 'true', wip: 'false', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [first_demand, fifth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'true', grouped_by_customer: 'false', not_started: 'true', wip: 'false', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [first_demand, fifth_demand]
                expect(assigns(:grouped_delivered_demands)).to eq({})
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'false', grouped_by_customer: 'true', not_started: 'true', wip: 'false', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [first_demand, fifth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name]).to eq [first_demand]
                expect(assigns(:grouped_customer_demands)[other_customer.name]).to eq [fifth_demand]
              end
            end
          end
          context 'and passing the flow status filter committed' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'true', grouped_by_month: 'false', grouped_by_customer: 'false', not_started: 'false', wip: 'true', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [second_demand, sixth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'true', grouped_by_customer: 'false', not_started: 'false', wip: 'true', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [second_demand, sixth_demand]
                expect(assigns(:grouped_delivered_demands)).to eq({})
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'false', grouped_by_customer: 'true', not_started: 'false', wip: 'true', delivered: 'false' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [second_demand, sixth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name]).to eq [second_demand]
                expect(assigns(:grouped_customer_demands)[other_customer.name]).to eq [sixth_demand]
              end
            end
          end
          context 'and passing the flow status filter delivered' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'true', grouped_by_month: 'false', grouped_by_customer: 'false', not_started: 'false', wip: 'false', delivered: 'true' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'true', grouped_by_customer: 'false', not_started: 'false', wip: 'false', delivered: 'true' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_delivered_demands)[[2018, 4]]).to match_array [fourth_demand, third_demand, eigth_demand, seventh_demand]
                expect(assigns(:grouped_customer_demands)).to be_nil
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, id: team, no_grouping: 'false', grouped_by_month: 'false', grouped_by_customer: 'true', not_started: 'false', wip: 'false', delivered: 'true' }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands)).to match_array [third_demand, fourth_demand, seventh_demand, eigth_demand]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name]).to match_array [fourth_demand, third_demand]
                expect(assigns(:grouped_customer_demands)[other_customer.name]).to match_array [eigth_demand, seventh_demand]
              end
            end
          end
        end
        context 'having no data' do
          it 'assigns the instance variable and renders the template' do
            get :search_demands_by_flow_status, params: { company_id: company, id: team, not_started: 'true', wip: 'false', delivered: 'false' }, xhr: true
            expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :search_demands_by_flow_status, params: { company_id: 'foo', id: team }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'team' do
          before { get :search_demands_by_flow_status, params: { company_id: company, id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :search_demands_by_flow_status, params: { company_id: company, id: team }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
