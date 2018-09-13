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
    describe 'GET #product_options_for_customer' do
      before { get :product_options_for_customer, params: { company_id: 'foo', customer_id: 'bar' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
    describe 'GET #search_for_projects' do
      before { get :search_for_projects, params: { company_id: 'foo', status_filter: :executing }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
    describe 'GET #statistics' do
      before { get :statistics, params: { company_id: 'foo', id: 'foo' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #synchronize_jira' do
      before { put :synchronize_jira, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #finish_project' do
      before { put :finish_project, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }
    after { travel_back }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    describe 'GET #show' do
      let!(:first_project) { Fabricate :project, customer: customer, product: product, start_date: 2.weeks.ago, end_date: Time.zone.today }

      context 'having results' do
        let!(:first_result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago }
        let!(:second_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago }
        let!(:first_alert) { Fabricate :project_risk_alert, project: first_project, created_at: 1.week.ago }
        let!(:second_alert) { Fabricate :project_risk_alert, project: first_project, created_at: Time.zone.now }

        let!(:first_demand) { Fabricate :demand, project: first_project, project_result: first_result, end_date: Date.new(2018, 3, 10), leadtime: 2000 }
        let!(:second_demand) { Fabricate :demand, project: first_project, project_result: first_result, end_date: Date.new(2018, 3, 25), leadtime: 6000 }
        let!(:third_demand) { Fabricate :demand, project: first_project, project_result: second_result, end_date: nil }

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
      context 'passing an invalid ID' do
        context 'non-existent' do
          before { get :show, params: { company_id: company, customer_id: customer, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      context 'having projects' do
        let(:customer) { Fabricate :customer, company: company }
        let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
        context 'not passing status filter' do
          let!(:project) { Fabricate :project, customer: customer, product: product, end_date: 2.days.from_now }
          let!(:other_project) { Fabricate :project, customer: customer, project_type: :consulting, product: nil, end_date: 5.days.from_now }
          let!(:other_company_project) { Fabricate :project, end_date: 2.days.from_now }

          before { get :index, params: { company_id: company } }
          it 'assigns the instances variables and renders the template' do
            expect(response).to render_template :index
            projects = assigns(:projects)
            expect(projects).to eq [other_project, project]
            expect(assigns(:projects_summary)).to be_a ProjectsSummaryData
            expect(assigns(:projects_summary).projects).to eq [other_project, project]
          end
        end

        context 'passing filter' do
          context 'status waiting' do
            let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :waiting, end_date: 2.days.from_now }
            let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :waiting, end_date: 3.days.from_now }
            let!(:third_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 4.days.from_now }
            before { get :index, params: { company_id: company, status_filter: :waiting } }
            it { expect(assigns(:projects_summary).projects).to eq [second_project, first_project] }
          end
        end
      end

      context 'having no projects' do
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
          expect(assigns(:products)).to eq []
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
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, customer: customer, name: 'aaa' }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project: { customer_id: customer, product_id: product, name: 'foo', nickname: 'bar', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000, percentage_effort_to_bugs: 20 } } }
        it 'creates the new project and redirects to projects index' do
          expect(Project.last.name).to eq 'foo'
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
          expect(response).to redirect_to company_projects_path(company)
        end
      end

      context 'passing invalid' do
        context 'project parameters' do
          before { post :create, params: { company_id: company, project: { customer_id: customer, product_id: product, name: '' } } }
          it 'does not create the project and re-render the template with the errors' do
            expect(Project.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:project).errors.full_messages).to eq ['Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Data de Início não pode ficar em branco', 'Data Final não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
            expect(assigns(:products)).to eq [other_product, product]
          end
        end
        context 'customer' do
          let(:customer) { Fabricate :customer, company: company }

          before { post :create, params: { company_id: company, project: { customer_id: 'foo', product_id: product, name: 'foo', nickname: 'bar', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(assigns(:project).errors.full_messages).to eq ['Cliente não pode ficar em branco'] }
        end
        context 'product' do
          let(:customer) { Fabricate :customer, company: company }

          before { post :create, params: { company_id: company, project: { customer_id: customer, product_id: 'foo', name: 'foo', nickname: 'bar', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(assigns(:project).errors.full_messages).to eq ['Produto é obrigatório para projeto de outsourcing'] }
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
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, customer: customer, name: 'aaa' }
      let(:project) { Fabricate :project, customer: customer, product: product }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: project } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:products)).to eq [other_product, product]
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
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:other_product) { Fabricate :product, customer: customer, name: 'aaa' }
      let(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.day.ago, end_date: 7.weeks.from_now, initial_scope: 100 }
      let!(:project_result) { Fabricate :project_result, project: project, result_date: Time.zone.today, known_scope: 120 }
      let!(:other_project_result) { Fabricate :project_result, project: project, result_date: Time.zone.tomorrow, known_scope: 400 }

      context 'passing valid parameters' do
        context 'changing the deadline and the initial scope' do
          before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000, percentage_effort_to_bugs: 10 } } }
          it 'updates the project, register the deadline change, compute the results again and redirects to projects index' do
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
            expect(ProjectResult.first.known_scope).to eq 1000
            expect(ProjectResult.last.known_scope).to eq 1000
            expect(ProjectChangeDeadlineHistory.count).to eq 1
            expect(response).to redirect_to company_project_path(company, project)
          end
        end
        context 'not changing the deadline nor the initial scope' do
          it 'does not register any change in deadline and do not computes again the project results' do
            expect_any_instance_of(ProjectResult).to receive(:compute_flow_metrics!).never
            put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: project.end_date, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 100 } }
            expect(ProjectChangeDeadlineHistory.count).to eq 0
            expect(ProjectResult.first.known_scope).to eq 120
            expect(ProjectResult.last.known_scope).to eq 400
          end
        end
      end

      context 'passing invalid' do
        context 'project parameters' do
          before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product, name: '', status: nil, project_type: nil, start_date: nil, end_date: nil, value: nil, qty_hours: nil, hour_value: nil, initial_scope: nil } } }
          it 'does not update the project and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:products)).to eq [other_product, product]
            expect(assigns(:project).errors.full_messages).to eq ['Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Data de Início não pode ficar em branco', 'Data Final não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
          end
        end
        context 'project' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: 'foo', project: { customer_id: customer, product_id: product.id, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'customer' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: project, project: { customer_id: 'foo', product_id: product, name: 'foo', nickname: 'bar', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(assigns(:project).errors.full_messages).to eq ['Cliente não pode ficar em branco'] }
        end
        context 'product' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: 'foo', name: 'foo', nickname: 'bar', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(assigns(:project).errors.full_messages).to eq ['Produto é obrigatório para projeto de outsourcing'] }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product.id, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #product_options_for_customer' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'valid parameters' do
        context 'having data' do
          let!(:first_product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:second_product) { Fabricate :product, customer: customer, name: 'aaa' }
          let!(:third_product) { Fabricate :product, name: 'aaa' }
          before { get :product_options_for_customer, params: { company_id: company, customer_id: customer }, xhr: true }
          it 'assigns the instance variable and renders the templates' do
            expect(assigns(:products)).to eq [second_product, first_product]
            expect(response).to render_template 'projects/product_options.js.erb'
          end
        end
        context 'having no data' do
          before { get :product_options_for_customer, params: { company_id: company, customer_id: customer }, xhr: true }
          it 'assigns the instance variable as empty array and renders the templates' do
            expect(assigns(:products)).to eq []
            expect(response).to render_template 'projects/product_options.js.erb'
          end
        end
      end

      context 'invalid parameters' do
        context 'no customer passed' do
          before { get :product_options_for_customer, params: { company_id: company }, xhr: true }
          it 'assigns the instance variable as empty array and renders the templates' do
            expect(assigns(:products)).to eq []
            expect(response).to render_template 'projects/product_options.js.erb'
          end
        end
        context 'unpermitted company' do
          let(:unpermitted_company) { Fabricate :company }
          before { get :product_options_for_customer, params: { company_id: unpermitted_company }, xhr: true }
          it { expect(response.status).to eq 404 }
        end
      end
    end

    describe 'GET #search_for_projects' do
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

      context 'passing valid parameters' do
        context 'having data' do
          let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 10.days.from_now }
          let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, end_date: 50.days.from_now }
          let!(:third_project) { Fabricate :project, customer: customer, product: product, status: :waiting, end_date: 15.days.from_now }
          let!(:other_company_project) { Fabricate :project, status: :executing }

          context 'and passing a status filter' do
            before { get :search_for_projects, params: { company_id: company, status_filter: :executing }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, first_project]
            end
          end
          context 'and passing no status filter' do
            before { get :search_for_projects, params: { company_id: company, status_filter: :all }, xhr: true }
            it 'assigns the instance variable and renders the template' do
              expect(response).to render_template 'projects/projects_search.js.erb'
              expect(assigns(:projects)).to eq [second_project, third_project, first_project]
            end
          end
        end
        context 'having no data' do
          let!(:other_company_project) { Fabricate :project, status: :executing }

          before { get :search_for_projects, params: { company_id: company, status_filter: :executing }, xhr: true }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template 'projects/projects_search.js.erb'
            expect(assigns(:projects)).to eq []
          end
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { get :search_for_projects, params: { company_id: 'foo', status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :search_for_projects, params: { company_id: company, status_filter: :executing }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: project } }
          it 'deletes the project and redirects' do
            expect(response).to redirect_to company_projects_path(company)
            expect(Project.last).to be_nil
          end
        end
        context 'having dependencies' do
          let!(:project) { Fabricate :project, customer: customer }
          let!(:project_result) { Fabricate :project_result, project: project }
          before { delete :destroy, params: { company_id: company, id: project } }

          it 'does delete the project and the dependecies' do
            expect(response).to redirect_to company_projects_path(company)
            expect(Project.last).to be_nil
            expect(flash[:error]).to be_blank
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

    describe 'PUT #synchronize_jira' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let!(:jira_config) { Fabricate :project_jira_config, project: project }

      context 'passing valid parameters' do
        it 'calls the services and the reader' do
          expect(Jira::ProcessJiraProjectJob).to receive(:perform_later).once
          put :synchronize_jira, params: { company_id: company, id: project }
          expect(response).to redirect_to company_project_path(company, project)
          expect(flash[:notice]).to eq I18n.t('general.enqueued')
        end
      end

      context 'invalid' do
        context 'project' do
          before { put :synchronize_jira, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company' do
          context 'non-existent' do
            before { put :synchronize_jira, params: { company_id: 'foo', id: project } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { put :synchronize_jira, params: { company_id: company, id: project } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #finish_project' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }

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
      let!(:project) { Fabricate :project, customer: customer }

      context 'passing valid parameters' do
        before { get :statistics, params: { company_id: company, id: project }, xhr: true }
        it 'assigns the instance variable and renders the template' do
          expect(project).to eq project
          expect(company).to eq company
          expect(response).to render_template 'projects/project_statistics.js.erb'
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
  end
end
