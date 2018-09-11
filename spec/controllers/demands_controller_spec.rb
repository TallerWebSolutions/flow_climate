# frozen_string_literal: true

RSpec.describe DemandsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo', project_result_id: 'xpto', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo', project_result_id: 'xpto', project_id: 'bar' } }
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
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:team) { Fabricate :team, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }
    let(:project) { Fabricate :project, customer: customer, product: product }
    let(:project_result) { Fabricate :project_result, team: team, project: project }

    before { sign_in user }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_result_id: project_result, project_id: project } }
        it 'instantiates a new Demand and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:demand)).to be_a_new Demand
        end
      end

      context 'invalid' do
        context 'company' do
          before { get :new, params: { company_id: 'foo', project_result_id: project_result, project_id: project } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { get :new, params: { company_id: company, project_result_id: project_result, project_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { get :new, params: { company_id: company, project_result_id: project_result, project_id: project } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let(:date_to_demand) { 1.day.ago.change(usec: 0) }
        it 'creates the new demand and redirects' do
          expect(ProjectResultService.instance).to receive(:compute_demand!).with(project.current_team, instance_of(Demand)).once
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
          expect(DemandsRepository.instance).to receive(:full_demand_destroy!).with(demand).once.and_call_original
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
      let(:project) { Fabricate :project, customer: customer }
      let!(:demand) { Fabricate :demand, created_date: created_date }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          expect(ProjectResultService.instance).to receive(:compute_demand!).with(project.current_team, instance_of(Demand)).once

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
            expect(ProjectResultService.instance).to receive(:compute_demand!).never
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
      let!(:deleted_demand) { Fabricate :demand, project: project, end_date: Time.zone.today, discarded_at: Time.zone.yesterday }

      context 'valid parameters' do
        it 'calls the to_csv and responds success' do
          get :demands_csv, params: { company_id: company, demands_ids: Demand.all.map(&:id).to_csv }, format: :csv
          expect(response).to have_http_status 200

          csv = CSV.parse(response.body, headers: true)
          expect(csv.count).to eq 1
          expect(csv.first[0].to_i).to eq demand.id
          expect(csv.first[1]).to eq demand.demand_id
          expect(csv.first[2]).to eq 'feature'
          expect(csv.first[3]).to eq 'standard'
          expect(csv.first[4].to_f).to eq demand.effort_downstream.to_f
          expect(csv.first[5].to_f).to eq demand.effort_upstream.to_f
          expect(csv.first[6]).to eq demand.created_date.to_s
          expect(csv.first[7]).to be_nil
          expect(csv.first[8]).to eq demand.end_date.to_s
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
        context 'for team' do
          let(:first_project) { Fabricate :project, customer: customer, product: product }
          let(:second_project) { Fabricate :project, customer: customer, product: product }

          let!(:first_demand) { Fabricate :demand, project: first_project }
          let!(:second_demand) { Fabricate :demand, project: second_project }

          it 'builds the operation report and respond the JS render the template' do
            get :demands_in_projects, params: { company_id: company, projects_ids: [first_project, second_project].map(&:id).to_csv }, xhr: true
            expect(response).to render_template 'demands/demands_list.js.erb'
            expect(assigns(:demands)).to match_array [first_demand, second_demand]
            expect(assigns(:demands_count_per_week)[first_project.start_date.beginning_of_week]).to eq(arrived_in_week: [], std_dev_arrived: 0.0, std_dev_throughput: 0.0, throughput_in_week: [])
          end
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
  end
end
