# frozen_string_literal: true

RSpec.describe DemandsController, type: :controller do
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
      before { delete :destroy, params: { company_id: 'foo', id: 'sbbrubles' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', project_id: 'bar', id: 'sbbrubles' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', project_id: 'bar', id: 'sbbrubles' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #synchronize_jira' do
      before { put :synchronize_jira, params: { company_id: 'foo', project_id: 'bar', id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #demands_csv' do
      before { get :demands_csv, params: { company_id: 'xpto' }, format: :csv }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'GET #demands_tab' do
      before { get :demands_tab, params: { company_id: 'xpto' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'POST #search_demands' do
      before { post :search_demands, params: { company_id: 'foo', id: 'foo', no_grouping: 'true', grouped_by_month: 'false', grouped_by_customer: 'false', not_started: 'false', wip: 'false', delivered: 'false' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy_physically' do
      before { delete :destroy_physically, params: { company_id: 'foo', id: 'sbbrubles' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'GET #score_research' do
      before { get :score_research, params: { company_id: 'foo', id: 'bar' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'POST #demands_list_by_ids' do
      before { get :demands_list_by_ids, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:team) { Fabricate :team, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }

    shared_context 'demands for controller specs' do
      let!(:first_demand) { Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15 }
      let!(:second_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0 }
      let!(:third_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: nil, end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10 }
      let!(:fourth_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 10, effort_upstream: 20 }

      let!(:fifth_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10 }
      let!(:sixth_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 10, effort_upstream: 10 }
      let!(:seventh_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 40, effort_upstream: 10 }
      let!(:eigth_demand) { Fabricate :demand, company: company, product: product, project: project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60 }
    end

    before do
      sign_in user

      allow_any_instance_of(User).to receive(:current_user_plan).and_return(user_plan)
    end

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
          post :create, params: { company_id: company, project_id: project, demand: { product_id: product, customer_id: customer, team_id: team, external_id: 'xpto', demand_type: 'bug', manual_effort: true, class_of_service: 'expedite', assignees_count: 3, effort_upstream: 5, effort_downstream: 2, created_date: date_to_demand, commitment_date: date_to_demand, end_date: date_to_demand, demand_score: 10.5 } }

          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project

          created_demand = Demand.last
          expect(created_demand.customer).to eq customer
          expect(created_demand.product).to eq product
          expect(created_demand.team).to eq team
          expect(created_demand.external_id).to eq 'xpto'
          expect(created_demand.demand_type).to eq 'bug'
          expect(created_demand.class_of_service).to eq 'expedite'
          expect(created_demand.demand_score).to eq 10.5
          expect(created_demand.downstream_demand?).to be true
          expect(created_demand.manual_effort).to be true
          expect(created_demand.effort_upstream).to eq 5
          expect(created_demand.effort_downstream.to_f).to eq 2
          expect(created_demand.created_date).to eq date_to_demand
          expect(created_demand.commitment_date).to eq date_to_demand
          expect(created_demand.end_date).to eq date_to_demand

          expect(response).to redirect_to company_demand_path(company, created_demand)
        end
      end

      context 'invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, demand: { finances: nil, income_total: nil, expenses_total: nil } } }

          it 'does not create the demand and re-render the template with the errors' do
            expect(Demand.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:demand).errors.full_messages).to eq ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco', 'Time não pode ficar em branco']
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
      context 'passing valid IDs' do
        it 'assigns the instance variable and renders the template' do
          travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
            project = Fabricate :project, company: company, customers: [customer], products: [product]

            first_demand = Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15
            second_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
            third_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: nil, end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10
            fourth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 10, effort_upstream: 20

            fifth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: 1.month.ago, commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10
            sixth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 10, effort_upstream: 10
            seventh_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 40, effort_upstream: 10
            eigth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60

            delete :destroy, params: { company_id: company, id: first_demand, demands_ids: Demand.all.map(&:id) }, xhr: true

            expect(response).to have_http_status :ok
            expect(response).to render_template 'demands/search_demands'
            expect(first_demand.reload.discarded_at).not_to be_nil
            expect(assigns(:start_date)).to eq 3.months.ago.to_date
            expect(assigns(:end_date)).to eq Time.zone.today
            expect(assigns(:demands).map(&:id)).to match_array [first_demand.id, second_demand.id, third_demand.id, fourth_demand.id, fifth_demand.id, sixth_demand.id, seventh_demand.id, eigth_demand.id]
            expect(assigns(:confidence_95_leadtime)).to be_within(0.1).of(4.6)
            expect(assigns(:confidence_80_leadtime)).to be_within(0.1).of(3.4)
            expect(assigns(:confidence_65_leadtime)).to be_within(0.1).of(2.2)
            expect(assigns(:avg_work_hours_per_demand).to_f).to be_within(0.1).of(36.8)
          end
        end
      end

      context 'passing an invalid ID' do
        let!(:first_demand) { Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15 }

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: first_demand, demands_ids: Demand.all.map(&:id) }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          let!(:first_demand) { Fabricate :demand, company: company, product: product, project: project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15 }

          before { delete :destroy, params: { company_id: company, id: first_demand, demands_ids: Demand.all.map(&:id) }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let!(:demand) { Fabricate :demand, company: company, product: product, project: project }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, project_id: project, id: demand, demands_ids: Demand.all.map(&:id) }, xhr: true }

        it 'assigns the instance variables and renders the template' do
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:demand)).to eq demand
          expect(assigns(:demands_ids)).to eq [demand.id]
          expect(response).to render_template 'demands/edit'
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', id: demand, demands_ids: Demand.all.map(&:id) }, xhr: true }

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

      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }
      let!(:demand) { Fabricate :demand, company: company, product: product, project: project, created_date: created_date }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          put :update, params: { company_id: company, project_id: project, id: demand, demands_ids: Demand.all.map(&:id), demand: { product_id: product, customer_id: customer, team_id: team, external_id: 'xpto', demand_type: 'bug', manual_effort: true, class_of_service: 'expedite', effort_upstream: 5, effort_downstream: 2, created_date: created_date, commitment_date: created_date, end_date: end_date, demand_score: 10.5 } }, xhr: true
          updated_demand = Demand.last
          expect(updated_demand.customer).to eq customer
          expect(updated_demand.product).to eq product
          expect(updated_demand.team).to eq team
          expect(updated_demand.external_id).to eq 'xpto'
          expect(updated_demand.demand_type).to eq 'bug'
          expect(updated_demand.downstream_demand?).to be true
          expect(updated_demand.manual_effort).to be true
          expect(updated_demand.class_of_service).to eq 'expedite'
          expect(updated_demand.demand_score).to eq 10.5
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
          before { put :update, params: { company_id: company, project_id: 'foo', id: demand, demands_ids: Demand.all.map(&:id) }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand parameters' do
          it 'does not update the demand and re-render the template with the errors' do
            put :update, params: { company_id: company, project_id: project, id: demand, demands_ids: Demand.all.map(&:id), demand: { external_id: '', demand_type: '', effort: nil, created_date: nil, commitment_date: nil, end_date: nil } }, xhr: true
            expect(response).to render_template 'demands/update'
            expect(assigns(:demand).errors.full_messages).to match_array ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco']
          end
        end

        context 'demand' do
          before { put :update, params: { company_id: company, project_id: project, id: 'bar', demands_ids: Demand.all.map(&:id) }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, id: demand, demands_ids: Demand.all.map(&:id), demand: { customer_id: customer, name: 'foo' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      include_context 'demands for controller specs'

      context 'passing a valid ID' do
        context 'with data' do
          let!(:demand_comment) { Fabricate :demand_comment, demand: first_demand, comment_date: 1.day.ago }
          let!(:other_demand_comment) { Fabricate :demand_comment, demand: first_demand, comment_date: 2.days.ago }

          let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.today, active: true }
          let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago }
          let!(:out_block) { Fabricate :demand_block, demand: second_demand }

          before { get :show, params: { company_id: company, id: first_demand } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:demand)).to eq first_demand
            expect(assigns(:demand_blocks)).to eq [second_block, first_block]
            expect(assigns(:queue_percentage)).to eq 0
            expect(assigns(:touch_percentage)).to eq 100
            expect(assigns(:upstream_percentage)).to eq 42.857142857142854
            expect(assigns(:downstream_percentage)).to eq 57.142857142857146
            expect(assigns(:demand_comments)).to eq [other_demand_comment, demand_comment]
            expect(assigns(:lead_time_breakdown)).to eq({})
          end
        end

        context 'without comments nor blocks' do
          let!(:demand) { Fabricate :demand, project: project }

          before { get :show, params: { company_id: company, id: first_demand } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:demand_blocks)).to eq []
            expect(assigns(:queue_percentage)).to eq 0
            expect(assigns(:touch_percentage)).to eq 100
            expect(assigns(:upstream_percentage)).to eq 42.857142857142854
            expect(assigns(:downstream_percentage)).to eq 57.142857142857146
            expect(assigns(:demand_comments)).to eq []
            expect(assigns(:lead_time_breakdown)).to eq({})
          end
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', id: first_demand } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          let(:demand) { Fabricate :demand, company: company }

          before { get :show, params: { company_id: company, id: demand } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'a different company' do
          let(:other_company) { Fabricate :company, users: [user] }
          let!(:demand) { Fabricate :demand, company: company, product: product }

          before { get :show, params: { company_id: other_company, id: demand } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      context 'passing a valid ID' do
        context 'with data' do
          it 'assigns the instance variable and renders the template' do
            travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
              first_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'first_demand', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 15
              second_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'second_demand', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
              third_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'third_demand', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: nil, end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10
              fourth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'fourth_demand', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 10, effort_upstream: 20

              fifth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'fifth_demand', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 30, effort_upstream: 10
              sixth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'sixth_demand', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 10, effort_upstream: 10
              seventh_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'seventh_demand', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 20, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 40, effort_upstream: 10
              eigth_demand = Fabricate :demand, company: company, product: product, project: project, demand_title: 'eigth_demand', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.today, effort_downstream: 50, effort_upstream: 60

              get :index, params: { company_id: company }

              expect(response).to render_template :index
              expect(assigns(:company)).to eq company
              expect(assigns(:paged_demands)).to eq [first_demand, fifth_demand, second_demand, sixth_demand, fourth_demand, eigth_demand, third_demand, seventh_demand]
              expect(assigns(:demands)).to eq [first_demand, fifth_demand, second_demand, sixth_demand, fourth_demand, eigth_demand, third_demand, seventh_demand]
              expect(assigns(:demands_ids)).to eq [first_demand.id, fifth_demand.id, second_demand.id, sixth_demand.id, fourth_demand.id, eigth_demand.id, third_demand.id, seventh_demand.id]

              expect(assigns(:confidence_95_leadtime).to_f).to eq 4.6
              expect(assigns(:confidence_80_leadtime).to_f).to eq 3.4000000000000004
              expect(assigns(:confidence_65_leadtime).to_f).to eq 2.2
              expect(assigns(:total_queue_time).to_f).to eq 0.0
              expect(assigns(:total_touch_time).to_f).to eq 0.0
              expect(assigns(:average_queue_time).to_f).to eq 0.0
              expect(assigns(:average_touch_time).to_f).to eq 0.0

              expect(assigns(:start_date)).to eq Date.new(2018, 10, 24)
              expect(assigns(:end_date)).to eq Date.new(2019, 1, 24)
            end
          end
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :index, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #synchronize_jira' do
      include_context 'demands for controller specs'

      let!(:jira_project_config) { Fabricate :jira_project_config, project: project }

      let(:first_card_response) { { data: { card: { id: '5140999', assignees: [{ id: '101381', username: 'xpto' }, { id: '101381', username: 'xpto' }, { id: '101382', username: 'bla' }, { id: '101321', username: 'mambo' }], comments: [{ created_at: '2018-02-22T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED]: xpto of bla having foo.' }], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: other_project.name }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '3481595' }, firstTimeIn: '2018-02-15T17:10:40-03:00', lastTimeOut: '2018-02-17T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-27T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.jira.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }

      context 'passing valid parameters' do
        context 'when there is no project change' do
          let(:first_card_response) { { data: { card: { id: '5140999', assignees: [{ id: '101381', username: 'xpto' }, { id: '101381', username: 'xpto' }, { id: '101382', username: 'bla' }, { id: '101321', username: 'mambo' }], comments: [{ created_at: '2018-02-22T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED]: xpto of bla having foo.' }], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: project.name }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '3481595' }, firstTimeIn: '2018-02-15T17:10:40-03:00', lastTimeOut: '2018-02-17T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-27T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.jira.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }

          it 'calls the services and the reader' do
            expect(Jira::ProcessJiraIssueJob).to receive(:perform_later)
            put :synchronize_jira, params: { company_id: company, project_id: project, id: first_demand }
            expect(response).to redirect_to company_demand_path(company, first_demand)
            expect(first_demand.reload.project).to eq project
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
          before { put :synchronize_jira, params: { company_id: company, project_id: 'foo', id: first_demand } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { put :synchronize_jira, params: { company_id: 'foo', project_id: project, id: first_demand } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { put :synchronize_jira, params: { company_id: company, project_id: project, id: first_demand } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #demands_csv' do
      let!(:demand) { Fabricate :demand, company: company, product: product, project: project, end_date: Time.zone.today }
      let!(:stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, stage_stream: :downstream, order: 0 }
      let!(:end_stage) { Fabricate :stage, company: company, projects: [project], commitment_point: false, end_point: true, order: 1, stage_stream: :downstream }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: end_stage }
      let!(:deleted_demand) { Fabricate :demand, company: company, product: product, project: project, end_date: Time.zone.today, discarded_at: Time.zone.yesterday }

      context 'valid parameters' do
        it 'calls the to_csv and responds success' do
          demand.update_effort!(false)

          get :demands_csv, params: { company_id: company, demands_ids: Demand.all.map(&:id).to_csv }, format: :csv
          expect(response).to have_http_status :ok

          csv = CSV.parse(response.body, headers: true)
          expect(csv.count).to eq 1
          expect(csv.first[0].to_i).to eq demand.id
          expect(csv.first[1]).to eq demand.portfolio_unit_name
          expect(csv.first[2]).to eq demand.current_stage&.name
          expect(csv.first[3].to_i).to eq demand.project_id
          expect(csv.first[4]).to eq demand.external_id
          expect(csv.first[5]).to eq demand.demand_title
          expect(csv.first[6]).to eq 'feature'
          expect(csv.first[7]).to eq 'standard'
          expect(csv.first[8]).to eq demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
          expect(csv.first[9]).to eq demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
          expect(csv.first[10]).to eq demand.demand_score.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
          expect(csv.first[11]).to eq demand.created_date.iso8601
          expect(csv.first[12]).to eq demand.commitment_date.iso8601
          expect(csv.first[13]).to eq demand.end_date.iso8601
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

    describe 'GET #demands_tab' do
      context 'with valid parameters' do
        context 'with unfinished projects' do
          it 'builds the operation report and respond the JS render the template' do
            travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
              first_project = Fabricate :project, customers: [customer], products: [product], start_date: 3.days.ago, end_date: 1.day.from_now, status: :executing
              second_project = Fabricate :project, customers: [customer], products: [product], start_date: 3.days.ago, end_date: 1.day.from_now, status: :finished

              first_demand = Fabricate :demand, company: company, product: product, project: first_project, created_date: 4.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.now
              second_demand = Fabricate :demand, company: company, product: product, project: second_project, created_date: 1.day.ago, commitment_date: 3.hours.ago, end_date: Time.zone.now

              third_demand = Fabricate :demand, company: company, product: product, project: second_project, created_date: 2.days.ago, commitment_date: 3.hours.ago, end_date: Time.zone.now, discarded_at: Time.zone.now

              get :demands_tab, params: { company_id: company, demands_ids: Demand.all.map(&:id).to_csv }, xhr: true
              expect(response).to render_template 'demands/demands_tab'
              expect(assigns(:start_date)).to eq 3.months.ago.to_date
              expect(assigns(:end_date)).to eq Time.zone.today
              expect(assigns(:demands).map(&:id)).to match_array [first_demand.id, second_demand.id]
              expect(assigns(:discarded_demands).map(&:id)).to eq [third_demand.id]
              expect(assigns(:confidence_95_leadtime).to_f).to eq 0.9562499999999999
              expect(assigns(:confidence_80_leadtime).to_f).to eq 0.8250000000000001
              expect(assigns(:confidence_65_leadtime).to_f).to eq 0.69375
            end
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :demands_tab, params: { company_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :demands_tab, params: { company_id: company }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #search_demands' do
      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }

      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }

      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let(:other_product) { Fabricate :product, customer: other_customer, name: 'aaa' }

      let!(:first_project) { Fabricate :project, name: 'qqq', customers: [customer], products: [product], status: :executing, start_date: Time.zone.local(2018, 12, 24, 10, 0, 0), end_date: Time.zone.local(2019, 2, 3, 10, 0, 0) }
      let!(:second_project) { Fabricate :project, customers: [other_customer], products: [other_product], status: :executing, start_date: Time.zone.local(2019, 1, 9, 10, 0, 0), end_date: Time.zone.local(2019, 3, 15, 10, 0, 0) }

      let(:start_date) { Project.all.map(&:start_date).min }
      let(:end_date) { Project.all.map(&:end_date).max }

      context 'passing valid parameters' do
        context 'having data' do
          context 'and passing the flow status all filters false' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  fifth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  seventh_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  eigth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  Fabricate :demand_block, demand: first_demand

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'no_grouping' }

                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id, second_demand.id, sixth_demand.id, eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 4.699999999999999
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.3).of(3.6)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.3).of(2.9)
                  expect(assigns(:avg_work_hours_per_demand).to_f).to eq 3.75
                end
              end
            end

            context 'grouped_by_month' do
              it 'finds the correct demands and responds with the correct JS' do
                travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  fifth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  seventh_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  eigth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'grouped_by_month' }

                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id, second_demand.id, sixth_demand.id, eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 4.699999999999999
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.3).of(3.6)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.3).of(2.9)
                end
              end
            end
          end

          context 'and passing the flow status filter not started' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  fifth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'no_grouping', flow_status: 'not_started' }

                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, fifth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0
                end
              end
            end
          end

          context 'and passing the flow status filter committed' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'no_grouping', flow_status: 'wip' }

                expect(response).to render_template 'demands/index'
                expect(assigns(:demands).map(&:id)).to match_array [second_demand.id, sixth_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end

            context 'grouped_by_month' do
              it 'finds the correct demands and responds with the correct JS' do
                Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'grouped_by_month', flow_status: 'wip' }

                expect(response).to render_template 'demands/index'
                expect(assigns(:demands).map(&:id)).to match_array [second_demand.id, sixth_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end

            context 'grouped_by_customer' do
              it 'finds the correct demands and responds with the correct JS' do
                Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'grouped_by_customer', flow_status: 'wip' }

                expect(response).to render_template 'demands/index'
                expect(assigns(:demands).map(&:id)).to match_array [second_demand.id, sixth_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 0
              end
            end
          end

          context 'and passing the flow status filter delivered' do
            context 'not grouped' do
              it 'finds the correct demands and responds with the correct JS' do
                Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                seventh_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                eigth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'no_grouping', flow_status: 'delivered' }

                expect(response).to render_template 'demands/index'
                expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 4.699999999999999
                expect(assigns(:confidence_80_leadtime)).to eq 3.8000000000000007
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(2.9000000000000004)
              end
            end

            context 'grouped_by_month' do
              it 'finds the correct demands and responds with the correct JS' do
                Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                seventh_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                eigth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, grouping: 'grouped_by_month', flow_status: 'delivered' }

                expect(response).to render_template 'demands/index'
                expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id, fourth_demand.id, seventh_demand.id, third_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 4.699999999999999
                expect(assigns(:confidence_80_leadtime)).to eq 3.8000000000000007
                expect(assigns(:confidence_65_leadtime)).to be_within(0.00001).of(2.90000)
              end
            end

            context 'and passing the filter by the demand type' do
              context 'feature' do
                it 'returns the feature demands' do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_type: 'feature' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, sixth_demand.id, third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.5).of(2.6)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.5).of(3.0)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.5).of(3.0)
                end
              end

              context 'bug' do
                it 'returns the bugs' do
                  Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_type: 'bug' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [second_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0
                  expect(assigns(:confidence_80_leadtime)).to eq 0
                  expect(assigns(:confidence_65_leadtime)).to eq 0
                end
              end

              context 'chore' do
                it 'returns the chores' do
                  travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                    Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                    fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                    post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_type: 'chore' }
                    expect(response).to render_template 'demands/index'
                    expect(assigns(:demands).map(&:id)).to eq [fourth_demand.id]
                    expect(assigns(:confidence_95_leadtime)).to eq 5.0
                    expect(assigns(:confidence_80_leadtime)).to eq 5.0
                    expect(assigns(:confidence_65_leadtime)).to eq 5.0
                  end
                end
              end

              context 'performance improvement' do
                it 'returns the performances demands' do
                  travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                    Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                    seventh_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                    post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_type: 'performance_improvement' }
                    expect(response).to render_template 'demands/index'
                    expect(assigns(:demands).map(&:id)).to eq [seventh_demand.id]
                    expect(assigns(:confidence_95_leadtime)).to eq 1.0
                    expect(assigns(:confidence_80_leadtime)).to eq 1.0
                    expect(assigns(:confidence_65_leadtime)).to eq 1.0
                  end
                end
              end

              context 'ui' do
                it 'returns the ui demands' do
                  Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  fifth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_type: 'ui' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [fifth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0
                  expect(assigns(:confidence_80_leadtime)).to eq 0
                  expect(assigns(:confidence_65_leadtime)).to eq 0
                end
              end

              context 'wireframe' do
                it 'returns the wireframe demands' do
                  Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  eigth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_type: 'wireframe' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [eigth_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 1.0
                  expect(assigns(:confidence_80_leadtime)).to eq 1.0
                  expect(assigns(:confidence_65_leadtime)).to eq 1.0
                end
              end
            end

            context 'and passing the filter by the class of service' do
              context 'standard' do
                it 'returns the standard demands' do
                  travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                    first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                    fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                    sixth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                    post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_class_of_service: 'standard' }
                    expect(response).to render_template 'demands/index'
                    expect(assigns(:demands).map(&:id)).to eq [first_demand.id, sixth_demand.id, fourth_demand.id]
                    expect(assigns(:confidence_95_leadtime)).to eq 5.0
                    expect(assigns(:confidence_80_leadtime)).to eq 5.0
                    expect(assigns(:confidence_65_leadtime)).to eq 5.0
                  end
                end
              end

              context 'fixed date' do
                it 'returns the fixed dates' do
                  travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                    Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                    fifth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                    eigth_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                    post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_class_of_service: 'fixed_date' }
                    expect(response).to render_template 'demands/index'
                    expect(assigns(:demands).map(&:id)).to eq [fifth_demand.id, eigth_demand.id]
                    expect(assigns(:confidence_95_leadtime)).to eq 1.0
                    expect(assigns(:confidence_80_leadtime)).to eq 1.0
                    expect(assigns(:confidence_65_leadtime)).to eq 1.0
                  end
                end
              end

              context 'intangible' do
                it 'returns the intagibles' do
                  travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                    Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                    third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                    post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_class_of_service: 'intangible' }
                    expect(response).to render_template 'demands/index'
                    expect(assigns(:demands).map(&:id)).to eq [third_demand.id]
                    expect(assigns(:confidence_95_leadtime)).to eq 3.0
                    expect(assigns(:confidence_80_leadtime)).to eq 3.0
                    expect(assigns(:confidence_65_leadtime)).to eq 3.0
                  end
                end
              end

              context 'expedite' do
                it 'returns the expeditees' do
                  travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                    Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                    second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                    Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                    seventh_demand = Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                    Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                    post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, demand_class_of_service: 'expedite' }
                    expect(response).to render_template 'demands/index'
                    expect(assigns(:demands).map(&:id)).to eq [second_demand.id, seventh_demand.id]
                    expect(assigns(:confidence_95_leadtime)).to eq 1.0
                    expect(assigns(:confidence_80_leadtime)).to eq 1.0
                    expect(assigns(:confidence_65_leadtime)).to eq 1.0
                  end
                end
              end
            end
          end

          context 'and passing a free search text' do
            context 'on demand title' do
              it 'returns the matches' do
                travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, search_text: 'foo' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, second_demand.id, third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to be_within(0.1).of(3)
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.1).of(3)
                  expect(assigns(:confidence_65_leadtime)).to be_within(0.1).of(3)
                end
              end
            end

            context 'on project name' do
              it 'returns the matches' do
                travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  third_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, search_text: 'qqq' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id, second_demand.id, fourth_demand.id, third_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 4.9
                  expect(assigns(:confidence_80_leadtime)).to be_within(0.3).of(4.3)
                  expect(assigns(:confidence_65_leadtime)).to eq 4.3
                end
              end
            end

            context 'on demand id' do
              it 'returns the matches' do
                travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                  first_demand = Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                  Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                  Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                  post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, search_text: 'hhh' }
                  expect(response).to render_template 'demands/index'
                  expect(assigns(:demands).map(&:id)).to eq [first_demand.id]
                  expect(assigns(:confidence_95_leadtime)).to eq 0
                  expect(assigns(:confidence_80_leadtime)).to eq 0
                  expect(assigns(:confidence_65_leadtime)).to eq 0
                end
              end
            end
          end

          context 'with search on tags' do
            it 'returns the matches' do
              travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
                Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
                second_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
                Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
                fourth_demand = Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
                Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

                post :search_demands, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(','), start_date: start_date, end_date: end_date, search_text: nil, search_demand_tags: 'xpto' }
                expect(response).to render_template 'demands/index'
                expect(assigns(:demands).map(&:id)).to eq [second_demand.id, fourth_demand.id]
                expect(assigns(:confidence_95_leadtime)).to eq 5.0
                expect(assigns(:confidence_80_leadtime)).to eq 5.0
                expect(assigns(:confidence_65_leadtime)).to eq 5.0
              end
            end
          end
        end

        context 'having no data' do
          it 'assigns the instance variable and renders the template' do
            travel_to Time.zone.local(2019, 1, 24, 10, 0, 0) do
              Fabricate :demand, company: company, product: product, project: first_project, external_id: 'hhh', demand_title: 'foo', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 20, effort_upstream: 0, demand_tags: %w[aaa ccc sbbrubles]
              Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'foo bar', demand_type: :bug, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0, demand_tags: %w[sbbrubles xpto]
              Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'bar foo', demand_type: :feature, class_of_service: :intangible, created_date: Time.zone.local(2019, 1, 19, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 20, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 10, demand_tags: %w[aaa ccc]
              Fabricate :demand, company: company, product: product, project: first_project, demand_title: 'xpto', demand_type: :chore, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 14, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 19, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0, demand_tags: %w[xpto]

              Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'xpto', demand_type: :ui, class_of_service: :fixed_date, created_date: Time.zone.local(2018, 12, 24, 10, 0, 0), commitment_date: nil, end_date: nil, effort_downstream: 0, effort_upstream: 0
              Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :feature, class_of_service: :standard, created_date: Time.zone.local(2019, 1, 23, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 24, 10, 0, 0), end_date: nil, effort_downstream: 0, effort_upstream: 0
              Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :performance_improvement, class_of_service: :expedite, created_date: Time.zone.local(2019, 1, 22, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 22, 10, 0, 0), end_date: Time.zone.local(2019, 1, 23, 10, 0, 0), effort_downstream: 0, effort_upstream: 0
              Fabricate :demand, company: company, product: product, project: second_project, demand_title: 'sas', demand_type: :wireframe, class_of_service: :fixed_date, created_date: Time.zone.local(2019, 1, 21, 10, 0, 0), commitment_date: Time.zone.local(2019, 1, 23, 10, 0, 0), end_date: Time.zone.local(2019, 1, 24, 10, 0, 0), effort_downstream: 0, effort_upstream: 0

              post :search_demands, params: { company_id: company, demands_ids: ['foo'], start_date: start_date, end_date: end_date, not_started: 'true', wip: 'false', delivered: 'false' }
              expect(response).to render_template 'demands/index'
              expect(assigns(:confidence_95_leadtime)).to eq 0
              expect(assigns(:confidence_80_leadtime)).to eq 0
              expect(assigns(:confidence_65_leadtime)).to eq 0
            end
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { post :search_demands, params: { company_id: 'foo', id: first_project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { post :search_demands, params: { company_id: company, id: first_project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy_physically' do
      let(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }

      let!(:demand) { Fabricate :demand, company: company, product: product, project: project }

      context 'passing valid IDs' do
        it 'assigns the instance variable and renders the template' do
          delete :destroy_physically, params: { company_id: company, id: demand }, xhr: true

          expect(response).to render_template 'demands/destroy_physically'
          expect(Demand.all.count).to eq 0
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent company' do
          before { delete :destroy_physically, params: { company_id: 'foo', id: demand }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy_physically, params: { company_id: company, id: demand }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #score_research' do
      include_context 'demands for controller specs'

      context 'passing a valid ID' do
        context 'with data' do
          context 'when the product does not have the score matrix yet' do
            it 'assigns the instance variable and renders the template' do
              expect(DemandScoreMatrixService.instance).to receive(:percentage_answered).once
              expect(DemandScoreMatrixService.instance).to receive(:current_position_in_backlog).once
              expect(DemandScoreMatrixService.instance).to(receive(:demands_list).once.and_return([1, 2]))
              get :score_research, params: { company_id: company, id: first_demand }

              expect(response).to render_template 'demands/score_matrix/score_research'
              expect(assigns(:company)).to eq company
              expect(assigns(:demand)).to eq first_demand
              expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
              expect(product.reload.score_matrix).to be_a ScoreMatrix
            end
          end

          context 'when the product already has the score matrix' do
            let!(:score_matrix) { Fabricate :score_matrix, product: product }

            it 'assigns the instance variable and renders the template' do
              get :score_research, params: { company_id: company, id: first_demand }

              expect(response).to render_template 'demands/score_matrix/score_research'
              expect(assigns(:company)).to eq company
              expect(assigns(:demand)).to eq first_demand
              expect(product.reload.score_matrix).to eq score_matrix
            end
          end
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :score_research, params: { company_id: 'foo', id: first_demand } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          let(:demand) { Fabricate :demand, company: company }

          before { get :score_research, params: { company_id: company, id: first_demand } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'a different company' do
          let(:other_company) { Fabricate :company, users: [user] }
          let!(:demand) { Fabricate :demand, company: company, product: product }

          before { get :score_research, params: { company_id: other_company, id: demand } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #demands_list_by_ids' do
      include_context 'demands for controller specs'

      context 'with no data' do
        it 'assigns the instance variable and renders the template' do
          get :demands_list_by_ids, params: { company_id: company }

          expect(response).to render_template 'demands/index'
          expect(assigns(:company)).to eq company
        end
      end

      context 'with data' do
        it 'assigns the instance variable and renders the template' do
          travel_to Time.zone.local(2019, 1, 19, 10, 0, 0) do
            get :demands_list_by_ids, params: { company_id: company, demands_ids: Demand.all.map(&:id).join(',') }

            expect(response).to render_template 'demands/index'
            expect(assigns(:company)).to eq company
            expect(assigns(:demands)).to match_array Demand.all

            expect(assigns(:confidence_95_leadtime)).to be_within(40).of 600
            expect(assigns(:confidence_80_leadtime)).to be_within(40).of 410
            expect(assigns(:confidence_65_leadtime)).to be_within(20).of 190
          end
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :demands_list_by_ids, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :demands_list_by_ids, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
