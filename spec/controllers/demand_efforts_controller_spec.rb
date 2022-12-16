# frozen_string_literal: true

RSpec.describe DemandEffortsController do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo', demand_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', demand_id: 'bar', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #update' do
      before { patch :update, params: { company_id: 'foo', demand_id: 'bar', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'GET #index' do
      context 'with valid params' do
        context 'with data' do
          it 'downloads the csv file' do
            demand = Fabricate :demand, company: company
            effort = Fabricate :demand_effort, demand: demand
            other_effort = Fabricate :demand_effort, demand: demand

            get :index, params: { company_id: company, demand_id: demand }, format: :csv

            csv = CSV.parse(response.body, headers: true)
            expect(csv.count).to eq 2
            expect(csv.pluck(0)).to match_array [effort.demand.external_id, other_effort.demand.external_id]
          end
        end

        context 'with no data' do
          it 'downloads the csv file' do
            demand = Fabricate :demand, company: company

            get :index, params: { company_id: company, demand_id: demand }, format: :csv

            csv = CSV.parse(response.body, headers: true)
            expect(csv.count).to eq 0
          end
        end
      end

      context 'with invalid params' do
        context 'demand' do
          before { get :index, params: { company_id: company, demand_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { get :index, params: { company_id: 'foo', demand_id: demand } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { get :index, params: { company_id: demand.company, demand_id: demand } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #edit' do
      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variable and renders the template' do
            demand = Fabricate :demand, company: company
            effort = Fabricate :demand_effort, demand: demand

            get :edit, params: { company_id: company, demand_id: demand, id: effort }

            expect(assigns(:company)).to eq company
            expect(assigns(:demand)).to eq demand
            expect(assigns(:demand_effort)).to eq effort
          end
        end
      end

      context 'with invalid params' do
        let(:demand) { Fabricate :demand, company: company }
        let(:effort) { Fabricate :demand_effort, demand: demand }

        context 'demand' do
          before { get :edit, params: { company_id: company, demand_id: 'foo', id: effort } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'effort' do
          before { get :edit, params: { company_id: company, demand_id: demand, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { get :index, params: { company_id: 'foo', demand_id: demand, id: effort } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { get :index, params: { company_id: demand.company, demand_id: demand, id: effort } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        context 'with data' do
          it 'updates the effort and redirects' do
            stage = Fabricate :stage, company: company, stage_stream: :downstream, queue: false
            customer = Fabricate :customer, company: company
            team = Fabricate :team, company: company
            project = Fabricate :project, company: company, customers: [customer], team: team

            Fabricate :stage_project_config, project: project, stage: stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10

            demand = Fabricate :demand, company: company, project: project, customer: customer, team: team, effort_upstream: 10, effort_downstream: 0
            assignment = Fabricate :item_assignment, demand: demand, start_time: 1.month.ago, finish_time: nil
            transition = Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: 1.month.ago, last_time_out: 2.weeks.ago

            contract = Fabricate :contract, customer: customer, start_date: 2.months.ago, end_date: 1.month.from_now

            effort = Fabricate :demand_effort, demand: demand, item_assignment: assignment, demand_transition: transition, start_time_to_computation: 28.days.ago, effort_value: 10

            expect(Consolidations::ProjectConsolidationJob).to(receive(:perform_later).with(project)).once
            expect(Consolidations::CustomerConsolidationJob).to(receive(:perform_later).with(customer)).once
            expect(Consolidations::ContractConsolidationJob).to(receive(:perform_later).with(contract)).once
            expect(Consolidations::TeamConsolidationJob).to(receive(:perform_later).with(team)).once
            expect(DemandEffortService.instance).to(receive(:update_demand_effort_caches).with(demand)).once

            patch :update, params: { company_id: company, demand_id: demand, id: effort, demand_effort: { effort_value: 30 } }

            expect(assigns(:company)).to eq company
            expect(assigns(:demand)).to eq demand
            expect(assigns(:demand_effort)).to eq effort
            expect(effort.reload.effort_value).to eq 30
          end
        end
      end

      context 'with invalid params' do
        let(:demand) { Fabricate :demand, company: company }
        let(:effort) { Fabricate :demand_effort, demand: demand }

        context 'demand' do
          before { patch :update, params: { company_id: company, demand_id: 'foo', id: effort } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'effort' do
          before { patch :update, params: { company_id: company, demand_id: demand, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { patch :update, params: { company_id: 'foo', demand_id: demand, id: effort } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { patch :update, params: { company_id: demand.company, demand_id: demand, id: effort } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
