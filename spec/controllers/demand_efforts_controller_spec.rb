# frozen_string_literal: true

RSpec.describe DemandEffortsController do
  context 'unauthenticated' do
    describe '#index' do
      before { get :index, params: { company_id: 'foo', demand_id: 'bar', id: 'meow' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe '#edit' do
      before { get :edit, params: { company_id: 'foo', demand_id: 'bar', id: 'meow' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe '#update' do
      before { patch :update, params: {company_id: 'foo', demand_id: 'bar', id: 'meow' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe '#index' do
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

    describe '#edit' do
      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            demand_effort = Fabricate :demand_effort, demand: demand

            get :edit, params: { company_id: company, demand_id: demand, id: demand_effort }

            expect(assigns(:demand_effort)).to eq demand_effort
            expect(assigns(:demand)).to eq demand
          end
        end

        context 'with no data' do
          it 'get the edit page' do
            demand = Fabricate :demand, company: company
            effort = Fabricate :demand_effort, demand: demand

            get :edit, params: { company_id: company, demand_id: demand, id: effort }

            expect(response).to have_http_status :ok
          end
        end
      end

      context 'with invalid params' do
        let(:project) { Fabricate :project, company: company }
        let(:team) { Fabricate :team, company: company }
        let(:demand) { Fabricate :demand, team: team, project: project }
        let(:effort) { Fabricate :demand_effort, demand: demand, effort_value: 4.0 }

        context 'demand' do
          before { get :edit, params: { company_id: company, demand_id: 'foo', id: effort } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'not found' do
            before { get :edit, params: { company_id: 'foo', demand_id: demand, id: effort } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { get :edit, params: { company_id: demand.company, demand_id: demand, id: effort } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe '#update' do
      context 'with valid params' do
        context 'with data' do
          it 'update effort data' do
            dev_membership = Fabricate :membership, member_role: :developer
            downstream_stage = Fabricate :stage, company: company, stage_stream: :downstream
            project = Fabricate :project, company: company
            demand = Fabricate :demand, company: company, project: project

            Fabricate :stage_project_config, stage: downstream_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
            transition = Fabricate :demand_transition, demand: demand, stage: downstream_stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
            assignment = Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')

            effort = Fabricate :demand_effort, demand: demand, effort_value: 4.0, start_time_to_computation: Time.zone.parse('2021-05-24 10:51'), demand_transition: transition, item_assignment: assignment

            put :update, params: { company_id: company, demand_id: demand, id: effort, demand_effort: { effort_value: 8.0 } }

            effort_update = effort.reload

            expect(effort_update.automatic_update).to be false
            expect(effort_update.effort_value).to eq 8.0
            expect(effort_update.effort_with_blocks).to eq 8.0
          end
        end
      end
    end
  end
end
