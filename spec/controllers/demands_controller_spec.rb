# frozen_string_literal: true

RSpec.describe DemandsController, type: :controller do
  before { travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) }
  after { travel_back }

  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', project_id: 'bar', id: 'sbbrubles' }, xhr: true }
      it { expect(response).to have_http_status :unauthorized }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', project_id: 'bar', id: 'sbbrubles' }, xhr: true }
      it { expect(response).to have_http_status 401 }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', project_id: 'bar', id: 'sbbrubles' }, xhr: true }
      it { expect(response).to have_http_status 401 }
    end
    describe 'PUT #synchronize_jira' do
      before { put :synchronize_jira, params: { company_id: 'foo', project_id: 'bar', id: 'bla' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #demands_csv' do
      before { get :demands_csv, params: { company_id: 'xpto' }, format: :csv }
      it { expect(response).to have_http_status 401 }
    end
    describe 'GET #demands_in_projects' do
      before { get :demands_in_projects, params: { company_id: 'xpto' }, xhr: true }
      it { expect(response).to have_http_status 401 }
    end
    describe 'GET #search_demands_by_flow_status' do
      before { get :search_demands_by_flow_status, params: { company_id: 'foo', id: 'foo', no_grouping: 'true', grouped_by_month: 'false', grouped_by_customer: 'false', not_started: 'false', wip: 'false', delivered: 'false' }, xhr: true }
      it { expect(response).to have_http_status 401 }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:team) { Fabricate :team, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }
    let(:project) { Fabricate :project, customer: customer, product: product }

    before { sign_in user }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project } }
        it 'instantiates a new Demand and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:demand)).to be_a_new Demand
        end
      end

      context 'invalid' do
        context 'company' do
          before { get :new, params: { company_id: 'foo', project_id: project } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { get :new, params: { company_id: company, project_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { get :new, params: { company_id: company, project_id: project } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let(:date_to_demand) { 1.day.ago.change(usec: 0) }
        it 'creates the new demand and redirects' do
          post :create, params: { company_id: company, project_id: project, demand: { demand_id: 'xpto', demand_type: 'bug', downstream: false, manual_effort: true, class_of_service: 'expedite', assignees_count: 3, effort_upstream: 5, effort_downstream: 2, created_date: date_to_demand, commitment_date: date_to_demand, end_date: date_to_demand } }

          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          created_demand = Demand.last
          expect(created_demand.demand_id).to eq 'xpto'
          expect(created_demand.demand_type).to eq 'bug'
          expect(created_demand.class_of_service).to eq 'expedite'
          expect(created_demand.downstream).to be false
          expect(created_demand.manual_effort).to be true
          expect(created_demand.assignees_count).to eq 3
          expect(created_demand.effort_upstream).to eq 5
          expect(created_demand.effort_downstream.to_f).to eq 2
          expect(created_demand.created_date).to eq date_to_demand
          expect(created_demand.commitment_date).to eq date_to_demand
          expect(created_demand.end_date).to eq date_to_demand
          expect(response).to redirect_to company_project_demand_path(company, project, created_demand)
        end
      end
      context 'invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, demand: { finances: nil, income_total: nil, expenses_total: nil } } }
          it 'does not create the demand and re-render the template with the errors' do
            expect(Demand.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:demand).errors.full_messages).to eq ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco', 'Qtd Responsáveis não pode ficar em branco']
          end
        end
        context 'company' do
          before { post :create, params: { company_id: 'foo', project_id: project, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { post :create, params: { company_id: company, project_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { post :create, params: { company_id: company, project_id: project, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:project) { Fabricate :project, customer: customer, product: product }
      let(:demand) { Fabricate :demand }

      context 'passing valid IDs' do
        it 'assigns the instance variable and renders the template' do
          delete :destroy, params: { company_id: company, project_id: project, id: demand }, xhr: true
          expect(response).to render_template 'demands/destroy.js.erb'
          expect(Demand.last.discarded_at).not_to be_nil
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', project_id: project, id: demand }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, project_id: 'foo', id: demand }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, project_id: project, id: demand }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let!(:demand) { Fabricate :demand }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, project_id: project, id: demand }, xhr: true }
        it 'assigns the instance variables and renders the template' do
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:demand)).to eq demand
          expect(response).to render_template 'demands/edit'
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', id: demand }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { get :edit, params: { company_id: company, project_id: project, id: 'bar' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', project_id: project, id: demand }, xhr: true }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, project_id: project, id: demand }, xhr: true }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:created_date) { 1.day.ago.change(usec: 0) }
      let(:end_date) { Time.zone.now.change(usec: 0) }

      let(:company) { Fabricate :company, users: [user] }

      let(:team) { Fabricate :team, company: company }
      let!(:team_member) { Fabricate(:team_member, monthly_payment: 100, team: team) }

      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, team: team }
      let(:project) { Fabricate :project, customer: customer, product: product }
      let!(:demand) { Fabricate :demand, project: project, created_date: created_date }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          put :update, params: { company_id: company, project_id: project, id: demand, demand: { demand_id: 'xpto', demand_type: 'bug', downstream: true, manual_effort: true, class_of_service: 'expedite', effort_upstream: 5, effort_downstream: 2, created_date: created_date, commitment_date: created_date, end_date: end_date } }, xhr: true
          updated_demand = Demand.last
          expect(updated_demand.demand_id).to eq 'xpto'
          expect(updated_demand.demand_type).to eq 'bug'
          expect(updated_demand.downstream).to be true
          expect(updated_demand.manual_effort).to be true
          expect(updated_demand.class_of_service).to eq 'expedite'
          expect(updated_demand.effort_upstream.to_f).to eq 5
          expect(updated_demand.effort_downstream.to_f).to eq 2
          expect(updated_demand.created_date).to eq created_date
          expect(updated_demand.commitment_date).to eq created_date
          expect(updated_demand.end_date).to eq end_date
          expect(response).to render_template 'demands/update'
        end
      end

      context 'passing invalid' do
        context 'project' do
          before { put :update, params: { company_id: company, project_id: 'foo', id: demand }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand parameters' do
          it 'does not update the demand and re-render the template with the errors' do
            put :update, params: { company_id: company, project_id: project, id: demand, demand: { demand_id: '', demand_type: '', effort: nil, created_date: nil, commitment_date: nil, end_date: nil } }, xhr: true
            expect(response).to render_template 'demands/update'
            expect(assigns(:demand).errors.full_messages).to match_array ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco']
          end
        end

        context 'demand' do
          before { put :update, params: { company_id: company, project_id: project, id: 'bar' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, id: demand, demand: { customer_id: customer, name: 'foo' } }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:project) { Fabricate :project, customer: product.customer, product: product, end_date: 5.days.from_now }
      let!(:first_demand) { Fabricate :demand }
      let!(:second_demand) { Fabricate :demand }

      context 'passing a valid ID' do
        context 'having data' do
          let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.today, active: true }
          let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago }
          let!(:out_block) { Fabricate :demand_block, demand: second_demand }
          before { get :show, params: { company_id: company, project_id: project, id: first_demand } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:demand)).to eq first_demand
            expect(assigns(:demand_blocks)).to eq [second_block, first_block]
            expect(assigns(:queue_percentage)).to eq 0
            expect(assigns(:touch_percentage)).to eq 100
            expect(assigns(:upstream_percentage)).to eq 0
            expect(assigns(:downstream_percentage)).to eq 100
          end
        end
        context 'having no demand_blocks' do
          let!(:demand) { Fabricate :demand, project: project }
          before { get :show, params: { company_id: company, project_id: project, id: first_demand } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:demand_blocks)).to eq []
            expect(assigns(:queue_percentage)).to eq 0
            expect(assigns(:touch_percentage)).to eq 100
            expect(assigns(:upstream_percentage)).to eq 0
            expect(assigns(:downstream_percentage)).to eq 100
          end
        end
      end
      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', project_id: project, id: first_demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { company_id: company, project_id: project, id: first_demand } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #synchronize_jira' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let(:other_project) { Fabricate :project, customer: other_customer }
      let!(:project_jira_config) { Fabricate :project_jira_config, project: project }
      let!(:demand) { Fabricate :demand, project: project }

      let(:first_card_response) { { data: { card: { id: '5140999', assignees: [{ id: '101381', username: 'xpto' }, { id: '101381', username: 'xpto' }, { id: '101382', username: 'bla' }, { id: '101321', username: 'mambo' }], comments: [{ created_at: '2018-02-22T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED]: xpto of bla having foo.' }], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: other_project.full_name }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '3481595' }, firstTimeIn: '2018-02-15T17:10:40-03:00', lastTimeOut: '2018-02-17T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-27T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.jira.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }

      context 'passing valid parameters' do
        context 'when there is no project change' do
          let(:first_card_response) { { data: { card: { id: '5140999', assignees: [{ id: '101381', username: 'xpto' }, { id: '101381', username: 'xpto' }, { id: '101382', username: 'bla' }, { id: '101321', username: 'mambo' }], comments: [{ created_at: '2018-02-22T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED]: xpto of bla having foo.' }], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: project.full_name }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '3481595' }, firstTimeIn: '2018-02-15T17:10:40-03:00', lastTimeOut: '2018-02-17T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-27T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.jira.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }
          it 'calls the services and the reader' do
            expect(Jira::ProcessJiraIssueJob).to receive(:perform_later)
            put :synchronize_jira, params: { company_id: company, project_id: project, id: demand }
            expect(response).to redirect_to company_project_demand_path(company, project, demand)
            expect(demand.reload.project).to eq project
            expect(flash[:notice]).to eq I18n.t('general.enqueued')
          end
        end
      end

      context 'invalid' do
        context 'demand' do
          before { put :synchronize_jira, params: { company_id: company, project_id: project, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { put :synchronize_jira, params: { company_id: company, project_id: 'foo', id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company' do
          context 'non-existent' do
            before { put :synchronize_jira, params: { company_id: 'foo', project_id: project, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { put :synchronize_jira, params: { company_id: company, project_id: project, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #demands_csv' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let!(:demand) { Fabricate :demand, project: project, end_date: Time.zone.today }
      let!(:stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, stage_stream: :downstream, order: 0 }
      let!(:end_stage) { Fabricate :stage, company: company, projects: [project], commitment_point: false, end_point: true, order: 1, stage_stream: :downstream }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: end_stage }
      let!(:deleted_demand) { Fabricate :demand, project: project, end_date: Time.zone.today, discarded_at: Time.zone.yesterday }

      context 'valid parameters' do
        it 'calls the to_csv and responds success' do
          get :demands_csv, params: { company_id: company, demands_ids: Demand.all.map(&:id).to_csv }, format: :csv
          expect(response).to have_http_status 200

          csv = CSV.parse(response.body, headers: true)
          expect(csv.count).to eq 1
          expect(csv.first[0].to_i).to eq demand.id
          expect(csv.first[1]).to eq demand.current_stage&.name
          expect(csv.first[2]).to eq demand.demand_id
          expect(csv.first[3]).to eq demand.demand_title
          expect(csv.first[4]).to eq 'feature'
          expect(csv.first[5]).to eq 'standard'
          expect(csv.first[6]).to eq demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
          expect(csv.first[7]).to eq demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
          expect(csv.first[8]).to eq demand.created_date.iso8601
          expect(csv.first[9]).to eq demand.commitment_date.iso8601
          expect(csv.first[10]).to eq demand.end_date.iso8601
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :demands_csv, params: { company_id: 'foo' }, format: :csv }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :demands_csv, params: { company_id: company }, format: :csv }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #demands_in_projects' do
      context 'passing valid parameters' do
        let(:first_project) { Fabricate :project, customer: customer, product: product, start_date: 3.days.ago, end_date: 1.day.from_now, status: :executing }
        let(:second_project) { Fabricate :project, customer: customer, product: product, start_date: 3.days.ago, end_date: 1.day.from_now, status: :finished }

        let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 1.day.ago, end_date: Time.zone.now }
        let!(:second_demand) { Fabricate :demand, project: second_project, commitment_date: 3.hours.ago, end_date: Time.zone.now }

        it 'builds the operation report and respond the JS render the template' do
          get :demands_in_projects, params: { company_id: company, projects_ids: [first_project, second_project].map(&:id).to_csv, period: :all }, xhr: true
          expect(response).to render_template 'demands/demands_tab.js.erb'
          expect(assigns(:demands).map(&:id)).to match_array [first_demand.id, second_demand.id]
          expect(assigns(:demands_count_per_week)[first_project.start_date.beginning_of_week]).to eq(arrived_in_week: [second_demand, first_demand], std_dev_arrived: 0.0, std_dev_throughput: 0.0, throughput_in_week: [second_demand, first_demand])
          expect(assigns(:confidence_95_leadtime).to_f).to eq 0.9562499999999999
          expect(assigns(:confidence_80_leadtime).to_f).to eq 0.8250000000000001
          expect(assigns(:confidence_65_leadtime).to_f).to eq 0.69375
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :demands_in_projects, params: { company_id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :demands_in_projects, params: { company_id: company }, xhr: true }
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
      let!(:first_project) { Fabricate :project, name: 'qqq', customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
      let!(:second_project) { Fabricate :project, customer: other_customer, product: other_product, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_demand) { Fabricate :demand, project: first_project, demand_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: 2.days.ago, commitment_date: nil, end_date: nil }
          let!(:second_demand) { Fabricate :demand, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil }
          let!(:third_demand) { Fabricate :demand, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago }
          let!(:fourth_demand) { Fabricate :demand, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: 10.days.ago, commitment_date: 5.days.ago, end_date: Time.zone.today }

          let!(:fifth_demand) { Fabricate :demand, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil }
          let!(:sixth_demand) { Fabricate :demand, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: 1.day.ago, commitment_date: Time.zone.today, end_date: nil }
          let!(:seventh_demand) { Fabricate :demand, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago }
          let!(:eigth_demand) { Fabricate :demand, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today }

          context 'and passing the flow status all filters false' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'no_grouping', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id, second_demand.id, sixth_demand.id, eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.02916)
                expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(2.20000)
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(0.8125)
              end
            end
            context 'grouped_by_month' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_month', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id, second_demand.id, sixth_demand.id, eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_delivered_demands)[[2019, 1]].map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.02916)
                expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(2.20000)
                expect(assigns(:confidence_65_leadtime)).to be_within(0.0001).of(0.8125)
              end
            end
            context 'grouped_customer_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_customer', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id, second_demand.id, sixth_demand.id, eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name].map(&:id)).to eq [first_demand.id, second_demand.id, fourth_demand.id, third_demand.id]
                expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.02916)
                expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(2.20000)
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(0.8125)
              end
            end
          end
          context 'and passing the flow status filter not started' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'no_grouping', flow_status: 'not_started', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
            context 'grouped_delivered_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_month', flow_status: 'not_started', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id]
                expect(assigns(:grouped_delivered_demands)).to eq({})
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
            context 'grouped_customer_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_customer', flow_status: 'not_started', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name].map(&:id)).to eq [first_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
          end
          context 'and passing the flow status filter committed' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'no_grouping', flow_status: 'wip', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to match_array [second_demand.id, sixth_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
            context 'grouped_by_month' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_month', flow_status: 'wip', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to match_array [second_demand.id, sixth_demand.id]
                expect(assigns(:grouped_delivered_demands)).to eq({})
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
            context 'grouped_by_customer' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_customer', flow_status: 'wip', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to match_array [second_demand.id, sixth_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name].map(&:id)).to eq [second_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
          end
          context 'and passing the flow status filter delivered' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'no_grouping', flow_status: 'delivered', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.34583)
                expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(3.63333)
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(2.9000000000000004)
              end
            end
            context 'grouped_by_month' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_month', flow_status: 'delivered', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_delivered_demands)[[2019, 1]].map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_customer_demands)).to be_nil
                expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.34583)
                expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(3.63333)
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(2.90000)
              end
            end
            context 'grouped_customer_demands' do
              it 'finds the correct demands and responds with the correct JS' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), grouping: 'grouped_by_customer', flow_status: 'delivered', period: :all }, xhr: true

                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:grouped_delivered_demands)).to be_nil
                expect(assigns(:grouped_customer_demands)[customer.name].map(&:id)).to eq [fourth_demand.id, third_demand.id]
                expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.345833)
                expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(3.633333)
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(2.9000000000000004)
              end
            end

            context 'and passing the filter by the demand type' do
              context 'feature' do
                it 'returns the feature demands' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_type: 'feature', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, sixth_demand.id, third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.000001).of(2.6999999999999997)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.000001).of(1.8000000000000003)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.000001).of(0.9000000000000001)
                end
              end
              context 'bug' do
                it 'returns the bugs' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_type: 'bug', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [second_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0
                  expect(assigns(:confidence_80_leadtime)).to eq 0
                  expect(assigns(:confidence_65_leadtime)).to eq 0
                end
              end
              context 'chore' do
                it 'returns the chores' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_type: 'chore', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [fourth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.58333)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(4.58333)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(4.58333)
                end
              end
              context 'performance improvement' do
                it 'returns the performances demands' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_type: 'performance_improvement', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [seventh_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 1.0
                  expect(assigns(:confidence_80_leadtime)).to eq 1.0
                  expect(assigns(:confidence_65_leadtime)).to eq 1.0
                end
              end
              context 'ui' do
                it 'returns the ui demands' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_type: 'ui', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [fifth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0
                  expect(assigns(:confidence_80_leadtime)).to eq 0
                  expect(assigns(:confidence_65_leadtime)).to eq 0
                end
              end
              context 'wireframe' do
                it 'returns the wireframe demands' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_type: 'wireframe', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(0.58333)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(0.58333)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(0.58333)
                end
              end
            end
            context 'and passing the filter by the class of service' do
              context 'standard' do
                it 'returns the standard demands' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_class_of_service: 'standard', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, sixth_demand.id, fourth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(4.12499)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(2.75000)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(1.37500)
                end
              end
              context 'fixed date' do
                it 'returns the fixed dates' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_class_of_service: 'fixed_date', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [fifth_demand.id, eigth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.00001).of(0.55416)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.00001).of(0.46666)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(0.37916)
                end
              end
              context 'intangible' do
                it 'returns the intagibles' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_class_of_service: 'intangible', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 3.0
                  expect(assigns(:confidence_80_leadtime)).to eq 3.0
                  expect(assigns(:confidence_65_leadtime)).to eq 3.0
                end
              end
              context 'expedite' do
                it 'returns the expeditees' do
                  get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), demand_class_of_service: 'expedite', period: :all }, xhr: true
                  expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                  expect(assigns(:demands).map(&:id)).to eq [second_demand.id, seventh_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0.95
                  expect(assigns(:confidence_80_leadtime)).to eq 0.8
                  expect(assigns(:confidence_65_leadtime)).to eq 0.65
                end
              end
            end
          end
          context 'and passing a free search text' do
            context 'on demand title' do
              it 'returns the matches' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), search_text: 'foo', period: :all }, xhr: true
                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, second_demand.id, third_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 2.6999999999999997
                expect(assigns(:confidence_80_leadtime)).to eq 1.8000000000000003
                expect(assigns(:confidence_65_leadtime)).to eq 0.9000000000000001
              end
            end

            context 'on project name' do
              it 'returns the matches' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), search_text: 'qqq', period: :all }, xhr: true
                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id, second_demand.id, fourth_demand.id, third_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 4.345833333333332
                expect(assigns(:confidence_80_leadtime)).to eq 3.6333333333333337
                expect(assigns(:confidence_65_leadtime)).to eq 2.8500000000000005
              end
            end

            context 'on product name' do
              it 'returns the matches' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), search_text: 'aaa', period: :all }, xhr: true
                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [fifth_demand.id, sixth_demand.id, eigth_demand.id, seventh_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0.9374999999999998
                expect(assigns(:confidence_80_leadtime)).to eq 0.7500000000000002
                expect(assigns(:confidence_65_leadtime)).to eq 0.5541666666666668
              end
            end
            context 'on demand id' do
              it 'returns the matches' do
                get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), search_text: 'hhh', period: :all }, xhr: true
                expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
                expect(assigns(:demands).map(&:id)).to eq [first_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0
                expect(assigns(:confidence_80_leadtime)).to eq 0
                expect(assigns(:confidence_65_leadtime)).to eq 0
              end
            end
          end
        end
        context 'having no data' do
          it 'assigns the instance variable and renders the template' do
            get :search_demands_by_flow_status, params: { company_id: company, projects_ids: Project.all.map(&:id).join(','), not_started: 'true', wip: 'false', delivered: 'false', period: :all }, xhr: true
            expect(response).to render_template 'demands/search_demands_by_flow_status.js.erb'
            expect(assigns(:confidence_95_leadtime)).to eq 0
            expect(assigns(:confidence_80_leadtime)).to eq 0
            expect(assigns(:confidence_65_leadtime)).to eq 0
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :search_demands_by_flow_status, params: { company_id: 'foo', id: first_project }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :search_demands_by_flow_status, params: { company_id: company, id: first_project }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
