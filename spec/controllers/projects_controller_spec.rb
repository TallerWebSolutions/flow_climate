# frozen_string_literal: true

RSpec.describe ProjectsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #statistics' do
      before { get :statistics, params: { company_id: 'foo', id: 'foo' }, xhr: true }

      it { expect(response.status).to eq 401 }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #finish_project' do
      before { put :finish_project, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #copy_stages_from' do
      before { patch :copy_stages_from, params: { company_id: 'foo', id: 'sbbrubles', project_to_copy_stages_from: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #risk_drill_down' do
      before { get :risk_drill_down, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #closing_dashboard' do
      before { get :closing_dashboard, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #status_report_dashboard' do
      before { get :status_report_dashboard, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #lead_time_dashboard' do
      before { get :lead_time_dashboard, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #search_projects' do
      before { get :search_projects, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #running_projects_charts' do
      before { get :running_projects_charts, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #update_consolidations' do
      before { get :update_consolidations, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #statistics_tab' do
      before { get :statistics_tab, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #search_projects_by_team' do
      before { get :search_projects_by_team, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #tasks_tab' do
      before { get :tasks_tab, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let!(:customer) { Fabricate :customer, company: company, name: 'zzz' }
    let!(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

    describe 'GET #show' do
      let!(:product) { Fabricate :product, company: company, customer: customer }
      let(:project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 2.weeks.ago, end_date: Time.zone.today }

      context 'with data' do
        context 'with running project' do
          it 'assigns the instance variables and renders the template' do
            travel_to Time.zone.local(2020, 12, 6, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 15.weeks.ago, end_date: Time.zone.today, status: :executing

              first_consolidation = Fabricate :project_consolidation, consolidation_date: 10.weeks.ago, project: first_project, operational_risk: 0.875, last_data_in_week: true, last_data_in_month: true
              second_consolidation = Fabricate :project_consolidation, consolidation_date: 9.weeks.ago, project: first_project, operational_risk: 0.875, last_data_in_week: true, last_data_in_month: true

              third_consolidation = Fabricate :project_consolidation, consolidation_date: 8.weeks.ago, project: first_project, operational_risk: 0.375, last_data_in_week: true, last_data_in_month: false

              fourth_consolidation = Fabricate :project_consolidation, consolidation_date: 7.weeks.ago, project: first_project, operational_risk: 0.375, last_data_in_week: false, last_data_in_month: true

              first_stage = Fabricate :stage, company: company, projects: [first_project], order: 1
              second_stage = Fabricate :stage, company: company, projects: [first_project], order: 0

              first_demand = Fabricate :demand, project: first_project, external_id: 'ccc', demand_score: 10.5, end_date: 2.days.ago
              second_demand = Fabricate :demand, project: first_project, external_id: 'zzz', commitment_date: 3.days.ago, end_date: 1.day.ago
              third_demand = Fabricate :demand, project: first_project, external_id: 'aaa', commitment_date: 1.day.ago, end_date: nil

              first_block = Fabricate :demand_block, demand: first_demand, block_time: 1.day.ago
              second_block = Fabricate :demand_block, demand: second_demand, block_time: Time.zone.now

              get :show, params: { company_id: company, id: first_project }

              expect(response).to have_http_status :ok
              expect(response).to render_template :show
              expect(assigns(:company)).to eq company
              expect(assigns(:project)).to eq first_project
              expect(assigns(:unscored_demands)).to eq [third_demand, second_demand]
              expect(assigns(:lead_time_histogram_data).keys.map(&:to_f)).to eq [43_200.0]
              expect(assigns(:lead_time_histogram_data).values.map(&:to_f)).to eq [2]
              expect(assigns(:last_10_deliveries).map(&:external_id)).to eq %w[zzz ccc]
              expect(assigns(:demands_blocks)).to eq [second_block, first_block]
              expect(assigns(:stages_list)).to eq [second_stage, first_stage]
              expect(assigns(:average_speed)).to eq 0.6666666666666666
              expect(assigns(:all_project_consolidations)).to eq [first_consolidation, second_consolidation, third_consolidation, fourth_consolidation]
              expect(assigns(:dashboard_project_consolidations_for_months)).to eq [first_consolidation, second_consolidation, fourth_consolidation]
            end
          end
        end

        context 'with ended project' do
          it 'renders consolidations for finished project' do
            travel_to Time.zone.local(2022, 1, 5, 19, 0) do
              project = Fabricate :project, company: company, start_date: 30.weeks.ago, end_date: 10.weeks.ago, status: :finished

              first_consolidation = Fabricate :project_consolidation, consolidation_date: 21.weeks.ago, project: project, operational_risk: 0.875, last_data_in_week: true, last_data_in_month: true
              second_consolidation = Fabricate :project_consolidation, consolidation_date: 19.weeks.ago, project: project, operational_risk: 0.875, last_data_in_week: true, last_data_in_month: true

              get :show, params: { company_id: company, id: project }

              expect(assigns(:all_project_consolidations)).to eq [first_consolidation, second_consolidation]
              expect(assigns(:dashboard_project_consolidations_for_months)).to eq [first_consolidation, second_consolidation]
            end
          end
        end
      end

      context 'with no data' do
        context 'passing valid IDs' do
          before { get :show, params: { company_id: company, customer_id: customer, id: project } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
          end
        end
      end

      context 'invalid' do
        context 'non-existent' do
          before { get :show, params: { company_id: company, customer_id: customer, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: company, customer_id: customer, id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'a different company' do
          let(:other_company) { Fabricate :company, users: [user] }
          let!(:project) { Fabricate :demand, company: company, product: product }

          before { get :show, params: { company_id: other_company, id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      context 'with projects' do
        let(:customer) { Fabricate :customer, company: company }
        let(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }

        let!(:project) { Fabricate :project, company: company, customers: [customer], products: [product], end_date: 2.days.from_now }
        let!(:other_project) { Fabricate :project, company: company, customers: [customer], project_type: :consulting, end_date: 5.days.from_now }
        let!(:other_company_project) { Fabricate :project, end_date: 2.days.from_now }

        before { get :index, params: { company_id: company } }

        it 'assigns the instances variables and renders the template' do
          expect(response).to render_template :index
          expect(assigns(:projects)).to eq [other_project, project]
          expect(assigns(:unpaged_projects)).to eq [other_project, project]
          expect(assigns(:projects_summary)).to be_a ProjectsSummaryData
          expect(assigns(:projects_summary).projects).to eq [other_project, project]
        end
      end

      context 'with no projects' do
        before { get :index, params: { company_id: company, status_filter: :waiting } }

        it { expect(assigns(:projects_summary).projects).to eq [] }
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }

        it 'instantiates a new Project and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:project)).to be_a_new Project
          expect(assigns(:company_customers)).to eq [other_customer, customer]
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let!(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, company: company, customer: customer, name: 'aaa' }
      let!(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project: { product_id: product, team_id: team.id, name: 'foo', nickname: 'bar', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000, percentage_effort_to_bugs: 20, max_work_in_progress: 2 } } }

        it 'creates the new project and redirects to projects index' do
          expect(Project.last.name).to eq 'foo'
          expect(Project.last.company).to eq company
          expect(Project.last.nickname).to eq 'bar'
          expect(Project.last.status).to eq 'executing'
          expect(Project.last.project_type).to eq 'outsourcing'
          expect(Project.last.start_date).to eq 1.day.ago.to_date
          expect(Project.last.end_date).to eq 1.day.from_now.to_date
          expect(Project.last.value).to eq 100.2
          expect(Project.last.qty_hours).to eq 300
          expect(Project.last.hour_value).to eq 200
          expect(Project.last.initial_scope).to eq 1000
          expect(Project.last.percentage_effort_to_bugs).to eq 20
          expect(Project.last.team).to eq team
          expect(Project.last.max_work_in_progress).to eq 2
          expect(response).to redirect_to company_projects_path(company)
        end
      end

      context 'passing invalid' do
        context 'project parameters' do
          before { post :create, params: { company_id: company, project: { product_id: product, name: '' } } }

          it 'does not create the project and re-render the template with the errors' do
            expect(Project.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:project).errors.full_messages).to eq ['Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Início não pode ficar em branco', 'Fim não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
            expect(assigns(:company_customers)).to eq [other_customer, customer]
          end
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { post :create, params: { company_id: company, project: { customer_id: customer, product_id: product, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:project) { Fabricate :project, company: company, customers: [customer] }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: project } }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:company_customers)).to eq [other_customer, customer]
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let!(:product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, company: company, customer: customer, name: 'aaa' }
      let(:project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 1.day.ago, end_date: 7.weeks.from_now, initial_scope: 100 }
      let!(:team) { Fabricate :team, company: company }

      context 'with valid parameters' do
        context 'when changing the deadline and the initial scope' do
          before { put :update, params: { company_id: company, id: project, project: { product_id: product, team_id: team.id, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000, percentage_effort_to_bugs: 10, max_work_in_progress: 3 } } }

          it 'updates the project, register the deadline change, compute the results again and redirects to projects index' do
            expect(Project.last.company).to eq company
            expect(Project.last.name).to eq 'foo'
            expect(Project.last.status).to eq 'executing'
            expect(Project.last.project_type).to eq 'outsourcing'
            expect(Project.last.start_date).to eq 1.day.ago.to_date
            expect(Project.last.end_date).to eq 1.day.from_now.to_date
            expect(Project.last.value).to eq 100.2
            expect(Project.last.qty_hours).to eq 300
            expect(Project.last.hour_value).to eq 200
            expect(Project.last.initial_scope).to eq 1000
            expect(Project.last.percentage_effort_to_bugs).to eq 10
            expect(ProjectChangeDeadlineHistory.count).to eq 1
            expect(Project.last.team).to eq team
            expect(Project.last.max_work_in_progress).to eq 3
            expect(response).to redirect_to company_project_path(company, project)
          end
        end

        context 'when changing the deadline to a previous date' do
          it 'updates the project, and finishes it' do
            expect(ProjectsRepository.instance).to(receive(:finish_project)).once

            put :update, params: { company_id: company, id: project, project: { start_date: 2.days.ago, end_date: 1.day.ago } }
            expect(response).to redirect_to company_project_path(company, project)
          end
        end

        context 'not changing the deadline nor the initial scope' do
          it 'does not register any change in deadline and do not computes again the project results' do
            put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: project.end_date, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 100 } }
            expect(ProjectChangeDeadlineHistory.count).to eq 0
          end
        end
      end

      context 'passing invalid' do
        context 'project parameters' do
          before { put :update, params: { company_id: company, id: project, project: { product_id: product, name: '', status: nil, project_type: nil, start_date: nil, end_date: nil, value: nil, qty_hours: nil, hour_value: nil, initial_scope: nil } } }

          it 'does not update the project and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:company_customers)).to eq [other_customer, customer]
            expect(assigns(:project).errors.full_messages).to eq ['Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Início não pode ficar em branco', 'Fim não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
          end
        end

        context 'project' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: 'foo', project: { customer_id: customer, product_id: product.id, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product.id, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company, customers: [customer] }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: project } }

          it 'deletes the project and redirects' do
            expect(response).to redirect_to company_projects_path(company)
            expect(Project.last).to be_nil
          end
        end

        context 'having restrictive dependencies' do
          let!(:project) { Fabricate :project, company: company, customers: [customer] }

          let!(:demand) { Fabricate :demand, project: project }

          before { delete :destroy, params: { company_id: company, id: project } }

          it 'does delete the project and the dependecies' do
            expect(response).to redirect_to company_projects_path(company)
            expect(Project.last).not_to be_nil
            expect(flash[:error]).to eq "#{I18n.t('project.destroy.error')} - #{assigns(:project).errors.full_messages.join(' | ')}"
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #finish_project' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, company: company, customers: [customer] }

      context 'passing valid parameters' do
        it 'finishes the project' do
          expect(ProjectsRepository.instance).to receive(:finish_project).with(project, project.end_date).once
          patch :finish_project, params: { company_id: company, id: project }
          expect(response).to redirect_to company_project_path(company, project)
          expect(flash[:notice]).to eq I18n.t('projects.finish_project.success_message')
        end
      end

      context 'invalid' do
        context 'project' do
          before { patch :finish_project, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :finish_project, params: { company_id: 'foo', id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :finish_project, params: { company_id: company, id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #statistics' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company, customers: [customer] }

      context 'passing valid parameters' do
        before { get :statistics, params: { company_id: company, id: project }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(project).to eq project
          expect(company).to eq company
          expect(response).to render_template 'projects/project_statistics'
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :statistics, params: { company_id: 'foo', id: project }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { get :statistics, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #copy_stages_from' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:stage_in_first_project) { Fabricate :stage, company: company }
      let!(:second_stage_in_first_project) { Fabricate :stage, company: company }
      let!(:stage_in_second_project) { Fabricate :stage, company: company }

      let!(:first_project) { Fabricate :project, company: company, stages: [second_stage_in_first_project] }
      let!(:second_project) { Fabricate :project, company: company, stages: [stage_in_second_project] }
      let!(:third_project) { Fabricate :project, company: company, stages: [second_stage_in_first_project] }

      let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage_in_first_project, project: first_project, stage_percentage: 20 }

      context 'with valid parameters' do
        context 'when there is no stages set in the receiver project' do
          it 'makes the copy of the stages to the receiver project with its configurations as well' do
            patch :copy_stages_from, params: { company_id: company, id: third_project, project_to_copy_stages_from: first_project }
            expect(response).to redirect_to company_project_stage_project_configs_path(company, third_project)
            expect(third_project.reload.stages).to match_array [stage_in_first_project, second_stage_in_first_project]
            expect(third_project.reload.stage_project_configs.map(&:stage_percentage)).to match_array [0, 20]
          end
        end

        context 'when there is stages already set in the receiver project' do
          it 'merges the stages' do
            patch :copy_stages_from, params: { company_id: company, id: second_project, project_to_copy_stages_from: first_project }, xhr: true
            expect(response).to redirect_to company_project_stage_project_configs_path(company, second_project)
            expect(second_project.reload.stages).to match_array [stage_in_second_project, stage_in_first_project, second_stage_in_first_project]
          end
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { patch :copy_stages_from, params: { company_id: company, id: 'foo', project_to_copy_stages_from: third_project }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent provider_stage' do
          before { patch :copy_stages_from, params: { company_id: company, id: third_project, project_to_copy_stages_from: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :copy_stages_from, params: { company_id: 'foo', id: third_project, project_to_copy_stages_from: third_project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :copy_stages_from, params: { company_id: company, id: third_project, project_to_copy_stages_from: third_project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #associate_customer' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:project) { Fabricate :project, company: company }

      let!(:customer) { Fabricate :customer, company: company, projects: [project] }
      let!(:other_customer) { Fabricate :customer, company: company, projects: [project] }

      context 'passing valid parameters' do
        it 'associates the customer and renders the template' do
          patch :associate_customer, params: { company_id: company, id: project, customer_id: customer }, xhr: true
          expect(response).to render_template 'projects/associate_dissociate_customer'
          expect(project.reload.customers).to match_array [customer, other_customer]
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { patch :associate_customer, params: { company_id: company, id: 'foo', customer_id: customer }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent customer' do
          before { patch :associate_customer, params: { company_id: company, id: 'foo', customer_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :associate_customer, params: { company_id: 'foo', id: project, customer_id: customer }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :associate_customer, params: { company_id: company, id: project, customer_id: customer }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #dissociate_customer' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:project) { Fabricate :project, company: company }

      let!(:customer) { Fabricate :customer, company: company, projects: [project] }
      let!(:other_customer) { Fabricate :customer, company: company, projects: [project] }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          patch :dissociate_customer, params: { company_id: company, id: project, customer_id: customer }, xhr: true
          expect(response).to render_template 'projects/associate_dissociate_customer'
          expect(project.reload.customers).to eq [other_customer]
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { patch :dissociate_customer, params: { company_id: company, id: 'foo', customer_id: customer }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent customer' do
          before { patch :dissociate_customer, params: { company_id: company, id: 'foo', customer_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :dissociate_customer, params: { company_id: 'foo', id: project, customer_id: customer }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :dissociate_customer, params: { company_id: company, id: project, customer_id: customer }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #associate_product' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company }

      let!(:product) { Fabricate :product, company: company, customer: customer, projects: [project] }
      let!(:other_product) { Fabricate :product, company: company, customer: customer, projects: [project] }

      context 'passing valid parameters' do
        it 'associates the product and renders the template' do
          patch :associate_product, params: { company_id: company, id: project, product_id: product }, xhr: true
          expect(response).to render_template 'projects/associate_dissociate_product'
          expect(project.reload.products).to match_array [product, other_product]
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { patch :associate_product, params: { company_id: company, id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { patch :associate_product, params: { company_id: company, id: 'foo', product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :associate_product, params: { company_id: 'foo', id: project, product_id: product }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :associate_product, params: { company_id: company, id: project, product_id: product }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #dissociate_product' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company }

      let!(:product) { Fabricate :product, company: company, customer: customer, projects: [project] }
      let!(:other_product) { Fabricate :product, company: company, customer: customer, projects: [project] }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          patch :dissociate_product, params: { company_id: company, id: project, product_id: product }, xhr: true
          expect(response).to render_template 'projects/associate_dissociate_product'
          expect(project.reload.products).to eq [other_product]
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { patch :dissociate_product, params: { company_id: company, id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { patch :dissociate_product, params: { company_id: company, id: 'foo', product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :dissociate_product, params: { company_id: 'foo', id: project, product_id: product }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :dissociate_product, params: { company_id: company, id: project, product_id: product }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #risk_drill_down' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company }

      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: Time.zone.today }
      let!(:other_project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago }

      let!(:out_project_consolidation) { Fabricate :project_consolidation }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :risk_drill_down, params: { company_id: company, id: project }, xhr: true

          expect(response).to render_template 'projects/risk_drill_down'
          expect(assigns(:project_consolidations)).to eq [other_project_consolidation, project_consolidation]
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { get :risk_drill_down, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :risk_drill_down, params: { company_id: 'foo', id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :risk_drill_down, params: { company_id: company, id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #closing_dashboard' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :closing_dashboard, params: { company_id: company, id: project }, xhr: true
          expect(response).to render_template 'projects/closing_info'
          expect(assigns(:project)).to eq project
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { get :closing_dashboard, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :closing_dashboard, params: { company_id: 'foo', id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :closing_dashboard, params: { company_id: company, id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #status_report_dashboard' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company, start_date: 2.weeks.ago, end_date: Time.zone.today }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          work_flow_info = instance_double('Flow::WorkItemFlowInformations', upstream_delivered_per_period: [], downstream_delivered_per_period: [], throughput_per_period: [])
          expect(Flow::WorkItemFlowInformations).to(receive(:new).once { work_flow_info })
          expect(work_flow_info).to(receive(:work_items_flow_behaviour).exactly(3).times)
          expect(work_flow_info).to(receive(:build_cfd_hash).exactly(3).times)

          get :status_report_dashboard, params: { company_id: company, id: project }, xhr: true
          expect(response).to render_template 'projects/status_report_dashboard'
          expect(assigns(:project)).to eq project
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { get :status_report_dashboard, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :status_report_dashboard, params: { company_id: 'foo', id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :status_report_dashboard, params: { company_id: company, id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #lead_time_dashboard' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :lead_time_dashboard, params: { company_id: company, id: project }, xhr: true
          expect(response).to render_template 'projects/lead_time_dashboard'
          expect(assigns(:project)).to eq project
        end
      end

      context 'passing an invalid' do
        context 'non-existent project' do
          before { get :lead_time_dashboard, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :lead_time_dashboard, params: { company_id: 'foo', id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :lead_time_dashboard, params: { company_id: company, id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #search_projects' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid parameters' do
        context 'with no search parameters' do
          it 'retrieves all the projects to the company' do
            travel_to Time.zone.local(2021, 5, 14, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO'
              second_project = Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO'
              third_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar'
              fourth_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo'

              get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(',') }

              expect(response).to render_template 'projects/index'
              expect(assigns(:projects)).to eq [fourth_project, third_project, second_project, first_project]
            end
          end
        end

        context 'with search by status' do
          it 'retrieves all executing the projects to the company' do
            travel_to Time.zone.local(2021, 5, 14, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO'
              second_project = Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO'
              third_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar'
              fourth_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo'

              get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), project_status: :executing }

              expect(response).to render_template 'projects/index'
              expect(assigns(:projects)).to eq [fourth_project, second_project]
            end
          end
        end

        context 'with search by start_date' do
          it 'retrieves all executing the projects to the company' do
            travel_to Time.zone.local(2021, 5, 14, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO'
              second_project = Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO'
              third_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar'
              fourth_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo'

              get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), projects_filter_start_date: 3.days.ago }

              expect(response).to render_template 'projects/index'
              expect(assigns(:projects)).to eq [fourth_project, third_project]
            end
          end
        end

        context 'with search by end_date' do
          it 'retrieves all executing the projects to the company' do
            travel_to Time.zone.local(2021, 5, 14, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO'
              second_project = Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO'
              third_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar'
              fourth_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo'

              get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), projects_filter_end_date: 16.days.ago }

              expect(response).to render_template 'projects/index'
              expect(assigns(:projects)).to eq [first_project]
            end
          end
        end

        context 'with search by status and start_date' do
          it 'retrieves all executing the projects to the company' do
            travel_to Time.zone.local(2021, 5, 14, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO'
              second_project = Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO'
              third_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar'
              fourth_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo'

              get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), project_status: :executing, projects_filter_start_date: 3.days.ago }

              expect(response).to render_template 'projects/index'
              expect(assigns(:projects)).to eq [fourth_project]
            end
          end
        end

        context 'with search by project name' do
          it 'retrieves all executing the projects to the company' do
            travel_to Time.zone.local(2021, 5, 14, 10, 0, 0) do
              first_project = Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO'
              second_project = Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO'
              third_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar'
              fourth_project = Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo'

              get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), project_name: 'bar' }

              expect(response).to render_template 'projects/index'
              expect(assigns(:projects)).to eq [third_project, first_project]
              expect(assigns(:unpaged_projects)).to eq [third_project, first_project]
            end
          end
        end
      end

      context 'passing an invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :search_projects, params: { company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :search_projects, params: { company_id: company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #search_projects_by_team' do
      context 'valid' do
        let(:team) { Fabricate :team, company: company }

        context 'with data' do
          it 'responds with projects by team' do
            first_project = Fabricate :project, company: company, team: team, name: 'zzz', status: :executing
            second_project = Fabricate :project, company: company, team: team, name: 'bbb', status: :maintenance
            third_project = Fabricate :project, company: company, team: team, name: 'ccc', status: :executing

            Fabricate :project, company: company, team: team, status: :waiting
            Fabricate :project, company: company, team: team, status: :finished
            Fabricate :project, company: company, status: :executing

            get :search_projects_by_team, params: { company_id: company, team_id: team }, xhr: true

            expect(response).to have_http_status :ok
            expect(response).to render_template 'flow_events/search_projects_by_team'
            expect(assigns(:projects_by_team)).to eq [second_project, third_project, first_project]
          end
        end

        context 'no data' do
          before { get :search_projects_by_team, params: { company_id: company, team_id: team }, xhr: true }

          it 'responds with projects by team' do
            expect(response).to have_http_status :ok
            expect(response).to render_template 'flow_events/search_projects_by_team'
            expect(assigns(:projects_by_team)).to eq []
          end
        end
      end

      context 'invalid' do
        context 'not permitted company' do
          let(:other_company) { Fabricate :company }
          let(:team) { Fabricate :team, company: other_company }

          before { get :search_projects_by_team, params: { company_id: other_company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not found company' do
          let(:team) { Fabricate :team }

          before { get :search_projects_by_team, params: { company_id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not found team' do
          before { get :search_projects_by_team, params: { company_id: company, team_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #running_projects_charts' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:first_project) { Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO' }
      let!(:second_project) { Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO' }
      let!(:third_project) { Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar' }
      let!(:fourth_project) { Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo' }

      context 'passing valid parameters' do
        context 'with no search parameters' do
          it 'retrieves all the projects to the company' do
            get :running_projects_charts, params: { company_id: company }, xhr: true

            expect(response).to render_template 'projects/running_projects_charts'
            expect(assigns(:running_projects_leadtime_data).keys).to match_array [second_project, fourth_project]
          end
        end
      end

      context 'passing an invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :running_projects_charts, params: { company_id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :running_projects_charts, params: { company_id: company }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #update_consolidations' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'with valid parameters' do
        it 'calls the consolidation job and notices the user' do
          travel_to Time.zone.local(2021, 1, 18, 10, 0, 0) do
            project = Fabricate :project, company: company, start_date: 3.weeks.ago, end_date: 1.day.from_now
            expect(Consolidations::ProjectConsolidationJob).to(receive(:perform_later)).exactly(22).times
            expect_any_instance_of(Project).to(receive(:remove_outdated_consolidations)).once

            patch :update_consolidations, params: { company_id: company, id: project }

            expect(response).to redirect_to company_project_path(company, project)
            expect(flash[:notice]).to eq I18n.t('general.enqueued')
          end
        end
      end

      context 'with invalid' do
        let!(:project) { Fabricate :project, company: company }

        context 'non-existent project' do
          before { patch :update_consolidations, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :update_consolidations, params: { company_id: 'foo', id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :update_consolidations, params: { company_id: company, id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #statistics_tab' do
      let!(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        context 'with no search parameters' do
          it 'retrieves all the projects to the company' do
            get :statistics_tab, params: { company_id: company, id: project }

            expect(response).to render_template 'projects/statistics_tab'
          end
        end
      end

      context 'passing an invalid' do
        context 'project' do
          before { get :statistics_tab, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :statistics_tab, params: { company_id: 'foo', id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :statistics_tab, params: { company_id: company, id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #tasks_tab' do
      let(:project) { Fabricate :project, company: company, customers: [customer] }

      context 'valid parameters' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            travel_to Time.zone.local(2022, 1, 28, 10, 0, 0) do
              demand = Fabricate :demand, project: project
              task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now
              other_task = Fabricate :task, demand: demand, created_date: 3.days.ago, end_date: Time.zone.now

              consolidation = Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, last_data_in_week: true
              other_consolidation = Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, last_data_in_week: true

              Fabricate :project_consolidation, project: project, consolidation_date: Time.zone.today, last_data_in_week: false
              Fabricate :project_consolidation, consolidation_date: 1.day.ago, last_data_in_week: true

              get :tasks_tab, params: { company_id: company, id: project }, xhr: true

              expect(response).to render_template 'projects/dashboards/tasks_dashboard'
              expect(assigns(:tasks_charts_adapter).tasks_in_chart).to eq [other_task, task]
              expect(assigns(:project_consolidations).map(&:consolidation_date)).to eq [consolidation.consolidation_date, other_consolidation.consolidation_date]
              expect(assigns(:burnup_adapter).work_items).to eq [other_task, task]
              expect(assigns(:task_completion_control_chart_data).items_ids).to eq [other_task.external_id, task.external_id]
              expect(assigns(:task_completion_control_chart_data).completion_times).to eq [other_task.seconds_to_complete, task.seconds_to_complete]
              expect(assigns(:company)).to eq company
              expect(assigns(:project)).to eq project
            end
          end
        end

        context 'with no data' do
          it 'assigns the instance variables and renders the empty template' do
            get :tasks_tab, params: { company_id: company, id: project }, xhr: true

            expect(response).to render_template 'projects/dashboards/tasks_dashboard'
            expect(response).to render_template 'layouts/_no_data'
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
          end
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :tasks_tab, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :tasks_tab, params: { company_id: 'foo', id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :tasks_tab, params: { company_id: company, id: project }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
