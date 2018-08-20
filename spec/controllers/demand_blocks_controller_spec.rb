# frozen_string_literal: true

RSpec.describe DemandBlocksController, type: :controller do
  context 'unauthenticated' do
    describe 'PATCH #activate' do
      before { patch :activate, params: { company_id: 'xpto', project_id: 'bar', project_result_id: 'bla', demand_id: 'foo', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #deactivate' do
      before { patch :deactivate, params: { company_id: 'xpto', project_id: 'bar', project_result_id: 'bla', demand_id: 'foo', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', project_id: 'bar', project_result_id: 'bla', demand_id: 'foo', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', project_id: 'bar', project_result_id: 'bla', demand_id: 'foo', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #index' do
      before { put :index, params: { company_id: 'xpto', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'PATCH #activate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: false }

      context 'passing valid parameters' do
        before { patch :activate, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_demand_path(company, project, demand)
          expect(demand_block.reload.active).to be true
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { patch :activate, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { patch :activate, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand' do
          before { patch :activate, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand_block' do
          before { patch :activate, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #deactivate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_demand_path(company, project, demand)
          expect(demand_block.reload.active).to be false
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { patch :deactivate, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { patch :deactivate, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand' do
          before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand_block' do
          before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { get :edit, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block }, xhr: true }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'demand_blocks/edit'
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { get :edit, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand' do
          before { get :edit, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand_block' do
          before { get :edit, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block, demand_block: { block_reason: 'foo', unblock_reason: 'bla', block_type: :specification_needed } }, xhr: true }
        it 'assigns the instance variable and renders the template' do
          updated_demand_block = assigns(:demand_block)
          expect(updated_demand_block.block_type).to eq 'specification_needed'
          expect(updated_demand_block.unblock_reason).to eq 'bla'
          expect(updated_demand_block.block_reason).to eq 'foo'
          expect(response).to render_template 'demand_blocks/update'
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { put :update, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { put :update, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand' do
          before { put :update, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'demand_block' do
          before { put :update, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer }
      let(:demand) { Fabricate :demand, project: project }
      let!(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { get :index, params: { company_id: company, project_id: project }, xhr: true }
        it 'assigns the instance variable and renders the template' do
          expect(project).to eq project
          expect(company).to eq company
          expect(response).to render_template 'demand_blocks/index'
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { get :index, params: { company_id: 'foo', project_id: project }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { get :index, params: { company_id: company, project_id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
