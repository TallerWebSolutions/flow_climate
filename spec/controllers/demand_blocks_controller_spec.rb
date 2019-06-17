# frozen_string_literal: true

RSpec.describe DemandBlocksController, type: :controller do
  context 'unauthenticated' do
    describe 'PATCH #activate' do
      before { patch :activate, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #deactivate' do
      before { patch :deactivate, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { put :index, params: { company_id: 'xpto', project_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #demands_blocks_tab' do
      before { get :demands_blocks_tab, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #demands_blocks_csv' do
      before { get :demands_blocks_csv, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    describe 'PATCH #activate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: false }

      context 'passing valid parameters' do
        before { patch :activate, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'demand_blocks/update'
          expect(demand_block.reload.active).to be true
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { patch :activate, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { patch :activate, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { patch :activate, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand_block' do
          before { patch :activate, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #deactivate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'demand_blocks/update'
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
      let!(:project) { Fabricate :project, customers: [customer] }
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
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block, demand_block: { block_type: :specification_needed } }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          updated_demand_block = assigns(:demand_block)
          expect(updated_demand_block.block_type).to eq 'specification_needed'
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
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, project: project }
      let!(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { get :index, params: { company_id: company, projects_ids: [project.id].join(',') }, xhr: true }

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
      end
    end

    describe 'GET #demands_blocks_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      let!(:first_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 6.days.ago, end_date: Time.zone.today }
      let!(:second_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 6.days.ago, end_date: Time.zone.today }

      context 'having data' do
        context 'passing valid parameters' do
          let!(:first_demand) { Fabricate :demand, project: first_project }
          let!(:second_demand) { Fabricate :demand, project: second_project }

          let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true }
          let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 3.days.ago, unblock_time: 2.days.ago, active: true }
          let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 4.days.ago, active: true }
          let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday, active: true }
          let!(:fifth_block) { Fabricate :demand_block, demand: first_demand, block_time: 5.days.ago, unblock_time: 3.days.ago, active: true }
          let!(:sixth_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: Time.zone.today, active: true }
          let!(:seventh_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: Time.zone.today, active: true, discarded_at: Time.zone.today }

          context 'no start nor end dates nor period provided' do
            it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
              get :demands_blocks_tab, params: { company_id: company, projects_ids: [first_project.id, second_project.id].join(',') }, xhr: true
              expect(response).to render_template 'demand_blocks/demands_blocks_tab'
              expect(assigns(:demands_blocks)).to eq [first_block, sixth_block, fourth_block, third_block, second_block, fifth_block]
            end
          end

          context 'and a start and end dates provided' do
            it 'builds the block list and render the template' do
              get :demands_blocks_tab, params: { company_id: company, projects_ids: [first_project.id, second_project.id].join(','), start_date: 2.days.ago, end_date: Time.zone.today }, xhr: true
              expect(response).to have_http_status :ok
              expect(assigns(:demands_blocks)).to eq [first_block, sixth_block, fourth_block, third_block]
              expect(response).to render_template 'demand_blocks/demands_blocks_tab'
            end
          end
        end
      end

      context 'having no data' do
        it 'render the template with empty data' do
          get :demands_blocks_tab, params: { company_id: company, projects_ids: [first_project.id, second_project.id].join(','), start_date: 2.days.ago, end_date: Time.zone.today }, xhr: true
          expect(assigns(:demands_blocks)).to eq []
          expect(response).to render_template 'demand_blocks/demands_blocks_tab'
        end
      end
    end

    describe 'GET #demands_blocks_csv' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customers: [customer], start_date: 2.days.ago, end_date: Time.zone.today }
      let!(:demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:demand_block) { Fabricate :demand_block, demand: demand, block_time: 1.day.ago, unblock_time: nil }

      context 'valid parameters' do
        it 'calls the to_csv and responds success' do
          get :demands_blocks_csv, params: { company_id: company, projects_ids: [project.id].join(',') }, format: :csv
          expect(response).to have_http_status :ok

          csv = CSV.parse(response.body, headers: true)
          expect(csv.count).to eq 1
          expect(csv.first[0].to_i).to eq demand_block.id
          expect(csv.first[1]).to eq demand_block.block_time&.iso8601
          expect(csv.first[2]).to eq demand_block.unblock_time&.iso8601
          expect(csv.first[3].to_i).to eq 0
          expect(csv.first[4]).to eq demand.demand_id
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :demands_blocks_csv, params: { company_id: 'foo', projects_ids: [project.id].join(',') }, format: :csv }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :demands_blocks_csv, params: { company_id: company, projects_ids: [project.id].join(',') }, format: :csv }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
