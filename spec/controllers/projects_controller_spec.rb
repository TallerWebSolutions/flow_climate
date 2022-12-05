# frozen_string_literal: true

RSpec.describe ProjectsController do
  context 'unauthenticated' do
    describe 'GET #show' do
      it 'renders the spa page' do
        get :show, params: { company_id: 'xpto', id: 'foo' }

        expect(response).to redirect_to new_user_session_path
      end
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

    describe 'GET #status_report_dashboard' do
      before { get :status_report_dashboard, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #lead_time_dashboard' do
      before { get :lead_time_dashboard, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #statistics_tab' do
      before { get :statistics_tab, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #financial_report' do
      before { get :financial_report, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #tasks_tab' do
      before { get :tasks_tab, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    let!(:customer) { Fabricate :customer, company: company, name: 'zzz' }
    let!(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

    describe 'GET #show' do
      let!(:product) { Fabricate :product, company: company, customer: customer }
      let(:project) { Fabricate :project, company: company, customers: [customer], products: [product], start_date: 2.weeks.ago, end_date: Time.zone.today }

      it 'renders project spa page' do
        get :show, params: { company_id: company, id: project }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #index' do
      context 'with projects' do
        before { get :index, params: { company_id: company } }

        it { expect(response).to render_template 'spa-build/index' }
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
            expect(assigns(:project).errors.full_messages).to eq ['Time deve existir', 'Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Início não pode ficar em branco', 'Fim não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
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

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :risk_drill_down, params: { company_id: company, id: project }, xhr: true

          expect(response).to render_template 'spa-build/index'
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

    describe 'GET #status_report_dashboard' do
      let(:company) { Fabricate :company, users: [user] }
      let(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :status_report_dashboard, params: { company_id: company, id: project }, xhr: true
          expect(response).to render_template 'spa-build/index'
        end
      end

      context 'passing an invalid' do
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
          expect(response).to render_template 'spa-build/index'
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

    describe 'GET #statistics_tab' do
      let!(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        context 'with no search parameters' do
          it 'renders spa page' do
            get :statistics_tab, params: { company_id: company, id: project }

            expect(response).to render_template 'spa-build/index'
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

    describe 'GET #financial_report' do
      let!(:project) { Fabricate :project, company: company }

      context 'passing valid parameters' do
        context 'with no search parameters' do
          it 'retrieves all the projects to the company' do
            get :financial_report, params: { company_id: company, id: project }

            expect(response).to render_template 'spa-build/index'
          end
        end
      end
    end

    describe 'GET #tasks_tab' do
      let!(:project) { Fabricate :project, company: company }

      it 'renders spa' do
        get :tasks_tab, params: { company_id: company, id: project }

        expect(response).to render_template 'spa-build/index'
      end
    end
  end
end
