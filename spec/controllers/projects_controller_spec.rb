# frozen_string_literal: true

RSpec.describe ProjectsController, type: :controller do
  before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

  after { travel_back }

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
      let!(:product) { Fabricate :product, customer: customer }
      let!(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 2.weeks.ago, end_date: Time.zone.today }

      context 'having results' do
        let!(:first_alert) { Fabricate :project_risk_alert, project: first_project, created_at: 1.week.ago }
        let!(:second_alert) { Fabricate :project_risk_alert, project: first_project, created_at: Time.zone.now }

        let!(:first_demand) { Fabricate :demand, project: first_project, demand_score: 10.5, end_date: Date.new(2018, 3, 10), leadtime: 2000 }
        let!(:second_demand) { Fabricate :demand, project: first_project, external_id: 'zzz', end_date: Date.new(2018, 5, 25), leadtime: 6000 }
        let!(:third_demand) { Fabricate :demand, project: first_project, external_id: 'aaa', end_date: nil }

        let!(:fourth_demand) { Fabricate :demand, end_date: Time.zone.today }
        let!(:first_change_deadline) { Fabricate :project_change_deadline_history, project: first_project }
        let!(:second_change_deadline) { Fabricate :project_change_deadline_history, project: first_project }

        context 'passing valid IDs' do
          before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }

          it 'assigns the instance variables and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq first_project
            expect(assigns(:ordered_project_risk_alerts)).to eq [second_alert, first_alert]
            expect(assigns(:project_change_deadline_histories)).to match_array [first_change_deadline, second_change_deadline]
            expect(assigns(:inconsistent_demands)).to eq [second_demand]
            expect(assigns(:unscored_demands)).to eq [third_demand, second_demand]
          end
        end
      end

      context 'having no results' do
        context 'passing valid IDs' do
          before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq first_project
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

          before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }

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
        let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

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
      let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, customer: customer, name: 'aaa' }
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
            expect(assigns(:project).errors.full_messages).to eq ['Time não pode ficar em branco', 'Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Início não pode ficar em branco', 'Fim não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
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
      let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, customer: customer, name: 'aaa' }
      let(:project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 1.day.ago, end_date: 7.weeks.from_now, initial_scope: 100 }
      let!(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        context 'changing the deadline and the initial scope' do
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
          expect(ProjectsRepository.instance).to receive(:finish_project!).with(project).once
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
            patch :copy_stages_from, params: { company_id: company, id: third_project, project_to_copy_stages_from: first_project }, xhr: true
            expect(response).to render_template 'stages/update_stages_table'
            expect(third_project.reload.stages).to match_array [stage_in_first_project, second_stage_in_first_project]
            expect(third_project.reload.stage_project_configs.map(&:stage_percentage)).to match_array [0, 20]
          end
        end

        context 'when there is stages already set in the receiver project' do
          it 'merges the stages' do
            patch :copy_stages_from, params: { company_id: company, id: second_project, project_to_copy_stages_from: first_project }, xhr: true
            expect(response).to render_template 'stages/update_stages_table'
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

      let!(:product) { Fabricate :product, customer: customer, projects: [project] }
      let!(:other_product) { Fabricate :product, customer: customer, projects: [project] }

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

      let!(:product) { Fabricate :product, customer: customer, projects: [project] }
      let!(:other_product) { Fabricate :product, customer: customer, projects: [project] }

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
      let!(:first_project) { Fabricate :project, company: company, start_date: 2.months.ago, end_date: 1.month.ago, status: :waiting, name: 'FooBarXpTO' }
      let!(:second_project) { Fabricate :project, company: company, start_date: 1.month.ago, end_date: 15.days.ago, status: :executing, name: 'XpTO' }
      let!(:third_project) { Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.day.ago, status: :finished, name: 'FooBar' }
      let!(:fourth_project) { Fabricate :project, company: company, start_date: 2.days.ago, end_date: 1.hour.ago, status: :executing, name: 'Foo' }

      context 'passing valid parameters' do
        context 'with no search parameters' do
          it 'retrieves all the projects to the company' do
            get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(',') }, xhr: true

            expect(response).to render_template 'projects/search_projects'
            expect(assigns(:projects)).to eq [fourth_project, third_project, second_project, first_project]
          end
        end

        context 'with search by status' do
          it 'retrieves all executing the projects to the company' do
            get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), project_status: :executing }, xhr: true

            expect(response).to render_template 'projects/search_projects'
            expect(assigns(:projects)).to eq [fourth_project, second_project]
          end
        end

        context 'with search by start_date' do
          it 'retrieves all executing the projects to the company' do
            get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), start_date: 3.days.ago }, xhr: true

            expect(response).to render_template 'projects/search_projects'
            expect(assigns(:projects)).to eq [fourth_project, third_project]
          end
        end

        context 'with search by end_date' do
          it 'retrieves all executing the projects to the company' do
            get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), end_date: 16.days.ago }, xhr: true

            expect(response).to render_template 'projects/search_projects'
            expect(assigns(:projects)).to eq [first_project]
          end
        end

        context 'with search by status and start_date' do
          it 'retrieves all executing the projects to the company' do
            get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), project_status: :executing, start_date: 3.days.ago }, xhr: true

            expect(response).to render_template 'projects/search_projects'
            expect(assigns(:projects)).to eq [fourth_project]
          end
        end

        context 'with search by project name' do
          it 'retrieves all executing the projects to the company' do
            get :search_projects, params: { company_id: company, projects_ids: [first_project, second_project, third_project, fourth_project].map(&:id).join(','), project_name: 'bar' }, xhr: true

            expect(response).to render_template 'projects/search_projects'
            expect(assigns(:projects)).to eq [third_project, first_project]
            expect(assigns(:unpaged_projects)).to eq [third_project, first_project]
          end
        end
      end

      context 'passing an invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :search_projects, params: { company_id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :search_projects, params: { company_id: company }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
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
            before { get :search_projects, params: { company_id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :search_projects, params: { company_id: company }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #update_consolidations' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        it 'calls the consolidation job and notices the user' do
          expect(Consolidations::ProjectConsolidationJob).to(receive(:perform_later)).once

          patch :update_consolidations, params: { company_id: company, id: project }

          expect(response).to redirect_to company_project_path(company, project)
          expect(flash[:notice]).to eq I18n.t('general.enqueued')
        end
      end

      context 'passing an invalid' do
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
  end
end
