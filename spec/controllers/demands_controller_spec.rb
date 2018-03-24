# frozen_string_literal: true

RSpec.describe DemandsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #synchronize_pipefy' do
      before { put :synchronize_pipefy, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'bla' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, customer: customer, product: product }

    before { sign_in user }

    describe 'GET #new' do
      let(:project_result) { Fabricate :project_result, project: project }

      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project, project_result_id: project_result } }
        it 'instantiates a new Demand and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
          expect(assigns(:demand)).to be_a_new Demand
        end
      end

      context 'invalid parameters' do
        context 'inexistent company' do
          before { get :new, params: { company_id: 'foo', project_id: project, project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project' do
          before { get :new, params: { company_id: company, project_id: 'foo', project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project_result' do
          before { get :new, params: { company_id: company, project_id: project, project_result_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted' do
          let(:company) { Fabricate :company }
          before { get :new, params: { company_id: company, project_id: project, project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:project_result) { Fabricate :project_result, project: project }

      context 'passing valid parameters' do
        let(:date_to_demand) { 1.day.ago.change(usec: 0) }
        it 'creates the new demand and redirects' do
          post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { demand_id: 'xpto', demand_type: 'bug', class_of_service: 'expedite', assignees_count: 3, effort: 5, created_date: date_to_demand, commitment_date: date_to_demand, end_date: date_to_demand } }

          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
          expect(assigns(:project_result).demands).to eq [Demand.last]

          expect(Demand.last.project_result).to eq project_result
          expect(Demand.last.demand_id).to eq 'xpto'
          expect(Demand.last.demand_type).to eq 'bug'
          expect(Demand.last.class_of_service).to eq 'expedite'
          expect(Demand.last.assignees_count).to eq 3
          expect(Demand.last.effort).to eq 5
          expect(Demand.last.created_date).to eq date_to_demand
          expect(Demand.last.commitment_date).to eq date_to_demand
          expect(Demand.last.end_date).to eq date_to_demand
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
        end
      end
      context 'passing invalid parameters' do
        context 'invalid attributes' do
          before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { finances: nil, income_total: nil, expenses_total: nil } } }
          it 'does not create the demand and re-render the template with the errors' do
            expect(Demand.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:demand).errors.full_messages).to eq ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco', 'Qtd Atribuídos não pode ficar em branco']
          end
        end
        context 'inexistent company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_result_id: project_result, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project_result' do
          before { post :create, params: { company_id: company, project_id: project, project_result_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:project) { Fabricate :project, customer: customer, product: product }
      let(:project_result) { Fabricate :project_result, project: project }
      let(:demand) { Fabricate :demand, project_result: project_result }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
          expect(Demand.last).to be_nil
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent project result' do
          before { delete :destroy, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', project_id: project, project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          let(:project_result) { Fabricate :project_result, project: project }

          before { delete :destroy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let(:project_result) { Fabricate :project_result, project: project }
      let!(:demand) { Fabricate :demand, project_result: project_result }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
          expect(assigns(:demand)).to eq demand
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'project_result' do
          before { get :edit, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: 'bar' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', project_id: project, project_result_id: project_result, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
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
      let!(:project_result) { Fabricate :project_result, project: project, result_date: created_date }
      let!(:demand) { Fabricate :demand, project_result: project_result, created_date: created_date }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand, demand: { demand_id: 'xpto', demand_type: 'bug', class_of_service: 'expedite', effort: 5, created_date: created_date, commitment_date: created_date, end_date: end_date } }
          updated_demand = Demand.last
          expect(updated_demand.demand_id).to eq 'xpto'
          expect(updated_demand.demand_type).to eq 'bug'
          expect(Demand.last.class_of_service).to eq 'expedite'
          expect(updated_demand.effort.to_f).to eq 5
          expect(updated_demand.created_date).to eq created_date
          expect(updated_demand.commitment_date).to eq created_date
          expect(updated_demand.end_date).to eq end_date
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
        end
      end

      context 'passing invalid' do
        context 'project' do
          before { put :update, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand parameters' do
          before { put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand, demand: { demand_id: '', demand_type: '', effort: nil, created_date: nil, commitment_date: nil, end_date: nil } } }
          it 'does not update the demand and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:demand).errors.full_messages).to match_array ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco']
          end
        end
        context 'non-existent project_result' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand, project_result: { customer_id: customer, name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: 'bar' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand, project_result: { customer_id: customer, name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:project) { Fabricate :project, customer: product.customer, product: product, end_date: 5.days.from_now }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:first_demand) { Fabricate :demand, project_result: project_result }
      let!(:second_demand) { Fabricate :demand, project_result: project_result }
      let(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.today }
      let(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago }
      let(:out_block) { Fabricate :demand_block, demand: second_demand }

      context 'passing a valid ID' do
        context 'having data' do
          before { get :show, params: { company_id: company, project_id: project, project_result_id: project_result, id: first_demand } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:project_result)).to eq project_result
            expect(assigns(:demand)).to eq first_demand
            expect(assigns(:demand_blocks)).to eq [second_block, first_block]
          end
        end
        context 'having no demand_blocks' do
          let!(:demand) { Fabricate :demand, project: project }
          before { get :show, params: { company_id: company, project_id: project, project_result_id: project_result, id: first_demand } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:demand_blocks)).to eq []
          end
        end
      end
      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', project_id: project, project_result_id: project_result, id: first_demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent project_result' do
          before { get :show, params: { company_id: company, project_id: project, project_result_id: project_result, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { company_id: company, project_id: project, project_result_id: project_result, id: first_demand } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #synchronize_pipefy' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project }
      let(:project_result) { Fabricate :project_result, project: project }
      let!(:demand) { Fabricate :demand, project: project, project_result: project_result }

      context 'passing valid parameters' do
        context 'when there is no project change' do
          it 'calls the services and the reader' do
            expect(PipefyApiService).to(receive(:request_card_details).with(demand.demand_id).once { 'response' })
            expect(PipefyReader.instance).to receive(:update_card!).with(pipefy_config.team, demand, 'response').once
            put :synchronize_pipefy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand }
            expect(response).to redirect_to company_project_project_result_demand_path(company, project, project_result, demand)
            expect(flash[:notice]).to eq I18n.t('demands.sync.done')
          end
        end
        context 'when there is no project change' do
          let(:other_project) { Fabricate :project, customer: customer }
          let(:other_project_result) { Fabricate :project_result, project: other_project }
          let!(:demand) { Fabricate :demand, project: other_project, project_result: other_project_result }
          it 'calls the services and the reader' do
            expect(PipefyApiService).to(receive(:request_card_details).with(demand.demand_id).once { 'response' })
            expect(PipefyReader.instance).to receive(:update_card!).with(pipefy_config.team, demand, 'response').once
            put :synchronize_pipefy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand }
            expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
            expect(flash[:notice]).to eq I18n.t('demands.sync.done')
          end
        end
      end

      context 'invalid' do
        context 'demand' do
          before { put :synchronize_pipefy, params: { company_id: company, project_id: project, project_result_id: project_result, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { put :synchronize_pipefy, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project_result' do
          before { put :synchronize_pipefy, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company' do
          context 'non-existent' do
            before { put :synchronize_pipefy, params: { company_id: 'foo', project_id: project, project_result_id: project_result, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { put :synchronize_pipefy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
