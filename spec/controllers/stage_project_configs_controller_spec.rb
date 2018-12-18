# frozen_string_literal: true

RSpec.describe StageProjectConfigsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', stage_id: 'bar', id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', stage_id: 'bar', id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    let(:company) { Fabricate :company, users: [user] }
    let(:upstream_stage) { Fabricate :stage, company: company, stage_stream: :upstream }
    let(:downstream_stage) { Fabricate :stage, company: company, stage_stream: :downstream }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: upstream_stage, stage_percentage: 10, pairing_percentage: 20, management_percentage: 45 }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: project, stage: downstream_stage, stage_percentage: 30, pairing_percentage: 3, management_percentage: 5 }

    before { sign_in user }

    describe 'GET #edit' do
      context 'valid parameters' do
        before { get :edit, params: { company_id: company, stage_id: upstream_stage, id: stage_project_config } }
        it 'assign the instances variables and renders the template' do
          expect(assigns(:company)).to eq company
          expect(assigns(:stage)).to eq upstream_stage
          expect(assigns(:stage_project_config)).to eq stage_project_config
          expect(response).to render_template :edit
        end
      end

      context 'and invalid' do
        context 'company' do
          before { get :edit, params: { company_id: 'foo', stage_id: upstream_stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stage' do
          before { get :edit, params: { company_id: company, stage_id: 'foo', id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stastage_project_configge' do
          before { get :edit, params: { company_id: company, stage_id: upstream_stage, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company authorization' do
          let(:company) { Fabricate :company }
          before { get :edit, params: { company_id: company, stage_id: upstream_stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
    describe 'PUT #update' do
      context 'valid parameters' do
        let(:second_project) { Fabricate :project, customer: customer }
        let!(:second_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: upstream_stage, stage_percentage: 7, pairing_percentage: 21, management_percentage: 27 }
        let!(:third_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: downstream_stage, stage_percentage: 18, pairing_percentage: 26, management_percentage: 33 }

        let!(:first_demand) { Fabricate :demand, project: project, effort_downstream: 23, effort_upstream: 17, manual_effort: true }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: first_demand, stage: upstream_stage, last_time_in: Time.zone.local(2018, 7, 25, 10, 0, 0), last_time_out: Time.zone.local(2018, 8, 1, 10, 0, 0) }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: first_demand, stage: downstream_stage, last_time_in: Time.zone.local(2018, 8, 3, 10, 0, 0), last_time_out: Time.zone.local(2018, 8, 10, 10, 0, 0) }

        let!(:second_demand) { Fabricate :demand, project: second_project, effort_downstream: 20, effort_upstream: 10, manual_effort: true }
        let!(:third_demand_transition) { Fabricate :demand_transition, demand: second_demand, stage: upstream_stage, last_time_in: Time.zone.local(2018, 7, 25, 10, 0, 0), last_time_out: Time.zone.local(2018, 8, 1, 10, 0, 0) }
        let!(:fourth_demand_transition) { Fabricate :demand_transition, demand: second_demand, stage: downstream_stage, last_time_in: Time.zone.local(2018, 8, 11, 10, 0, 0), last_time_out: Time.zone.local(2018, 8, 21, 10, 0, 0) }

        context 'not updating the manual effort' do
          it 'assign the instances variables and renders the template' do
            put :update, params: { company_id: company, stage_id: upstream_stage, id: stage_project_config, recompute_manual_efforts: '0', stage_project_config: { stage_percentage: 20, pairing_percentage: 40, management_percentage: 25 } }
            expect(assigns(:company)).to eq company
            expect(assigns(:stage)).to eq upstream_stage
            expect(assigns(:stage_project_config).stage_percentage).to eq 20
            expect(assigns(:stage_project_config).pairing_percentage).to eq 40
            expect(assigns(:stage_project_config).management_percentage).to eq 25
            expect(first_demand.reload.effort_upstream.to_f).to eq 17.0
            expect(first_demand.reload.effort_downstream.to_f).to eq 23.0

            expect(second_demand.reload.effort_upstream.to_f).to eq 10.0
            expect(second_demand.reload.effort_downstream.to_f).to eq 20.0
            expect(response).to redirect_to edit_company_stage_stage_project_config_path(company, upstream_stage, stage_project_config)
          end
        end

        context 'updating the manual effort' do
          it 'assign the instances variables and renders the template' do
            put :update, params: { company_id: company, stage_id: upstream_stage, id: stage_project_config, recompute_manual_efforts: '1', stage_project_config: { stage_percentage: 20, pairing_percentage: 40, management_percentage: 25 } }
            expect(assigns(:company)).to eq company
            expect(assigns(:stage)).to eq upstream_stage

            expect(assigns(:stage_project_config).stage_percentage).to eq 20
            expect(assigns(:stage_project_config).pairing_percentage).to eq 40
            expect(assigns(:stage_project_config).management_percentage).to eq 25

            expect(first_demand.reload.effort_upstream.to_f).to eq 7.5
            expect(first_demand.reload.effort_downstream.to_f).to eq 9.45

            expect(second_demand.reload.effort_upstream.to_f).to eq 10.0
            expect(second_demand.reload.effort_downstream.to_f).to eq 20.0
            expect(response).to redirect_to edit_company_stage_stage_project_config_path(company, upstream_stage, stage_project_config)
          end
        end
      end

      context 'and invalid' do
        context 'company' do
          before { put :update, params: { company_id: 'foo', stage_id: upstream_stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stage' do
          before { put :update, params: { company_id: company, stage_id: 'foo', id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stastage_project_configge' do
          before { put :update, params: { company_id: company, stage_id: upstream_stage, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company authorization' do
          let(:company) { Fabricate :company }
          before { put :update, params: { company_id: company, stage_id: upstream_stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
