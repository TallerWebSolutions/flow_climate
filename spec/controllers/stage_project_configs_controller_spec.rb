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

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:stage) { Fabricate :stage, company: company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: stage }

    before { sign_in user }

    describe 'GET #edit' do
      context 'valid parameters' do
        before { get :edit, params: { company_id: company, stage_id: stage, id: stage_project_config } }
        it 'assign the instances variables and renders the template' do
          expect(assigns(:company)).to eq company
          expect(assigns(:stage)).to eq stage
          expect(assigns(:stage_project_config)).to eq stage_project_config
          expect(response).to render_template :edit
        end
      end

      context 'and invalid' do
        context 'company' do
          before { get :edit, params: { company_id: 'foo', stage_id: stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stage' do
          before { get :edit, params: { company_id: company, stage_id: 'foo', id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stastage_project_configge' do
          before { get :edit, params: { company_id: company, stage_id: stage, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company authorization' do
          let(:company) { Fabricate :company }
          before { get :edit, params: { company_id: company, stage_id: stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
    describe 'PUT #update' do
      context 'valid parameters' do
        let(:second_project) { Fabricate :project, customer: customer }
        let!(:second_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: stage }

        let(:project_result) { Fabricate :project_result, project: project }
        let(:second_project_result) { Fabricate :project_result, project: second_project }

        let!(:first_demand) { Fabricate :demand, project: project, project_result: project_result, effort_downstream: 20, effort_upstream: 10 }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: Time.zone.local(2018, 7, 25, 10, 0, 0), last_time_out: Time.zone.local(2018, 8, 1, 10, 0, 0) }

        let!(:second_demand) { Fabricate :demand, project: second_project, project_result: second_project_result, effort_downstream: 20, effort_upstream: 10 }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: second_demand, stage: stage, last_time_in: Time.zone.local(2018, 7, 25, 10, 0, 0), last_time_out: Time.zone.local(2018, 8, 1, 10, 0, 0) }

        it 'assign the instances variables and renders the template' do
          expect_any_instance_of(ProjectResult).to receive(:compute_flow_metrics!).once
          put :update, params: { company_id: company, stage_id: stage, id: stage_project_config, stage_project_config: { stage_percentage: 20, pairing_percentage: 40, management_percentage: 25 } }
          expect(assigns(:company)).to eq company
          expect(assigns(:stage)).to eq stage
          expect(assigns(:stage_project_config).stage_percentage).to eq 20
          expect(assigns(:stage_project_config).pairing_percentage).to eq 40
          expect(assigns(:stage_project_config).management_percentage).to eq 25
          expect(response).to redirect_to edit_company_stage_stage_project_config_path(company, stage, stage_project_config)
        end
      end

      context 'and invalid' do
        context 'company' do
          before { put :update, params: { company_id: 'foo', stage_id: stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stage' do
          before { put :update, params: { company_id: company, stage_id: 'foo', id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'stastage_project_configge' do
          before { put :update, params: { company_id: company, stage_id: stage, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company authorization' do
          let(:company) { Fabricate :company }
          before { put :update, params: { company_id: company, stage_id: stage, id: stage_project_config } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
