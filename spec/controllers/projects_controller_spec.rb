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
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

    describe 'GET #show' do
      let!(:first_project) { Fabricate :project, customer: customer, product: product, end_date: 5.days.from_now }

      context 'having results' do
        let!(:first_result) { Fabricate :project_result, project: first_project, result_date: 2.days.ago }
        let!(:second_result) { Fabricate :project_result, project: first_project, result_date: 1.day.ago }

        context 'passing valid IDs' do
          before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq first_project
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
        context 'not passing status filter' do
          let(:customer) { Fabricate :customer, company: company }
          let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:project) { Fabricate :project, customer: customer, product: product, end_date: 2.days.from_now }
          let!(:other_project) { Fabricate :project, customer: customer, product: product, end_date: 5.days.from_now }
          let!(:other_company_project) { Fabricate :project, end_date: 2.days.from_now }

          before { get :index, params: { company_id: company } }
          it 'assigns the instances variables and renders the template' do
            expect(response).to render_template :index
            projects = assigns(:projects)
            expect(projects).to eq [other_project, project]
            expect(assigns(:projects_summary)).to be_a ProjectsSummaryObject
            expect(assigns(:projects_summary).projects).to eq [other_project, project]
          end
        end
        context 'passing status filter' do
          let(:customer) { Fabricate :customer, company: company }
          let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
          let!(:project) { Fabricate :project, customer: customer, product: product, status: :executing }
          let!(:other_project) { Fabricate :project, customer: customer, product: product, status: :waiting }
          let!(:other_company_project) { Fabricate :project, status: :executing }
          before { get :index, params: { company_id: company, status_filter: :executing } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :index
            expect(assigns(:projects)).to eq [project]
          end
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }
        it 'instantiates a new Project and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:project)).to be_a_new Project
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

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project: { customer_id: customer, product_id: product, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
        it 'creates the new project and redirects to projects index' do
          expect(Project.last.name).to eq 'foo'
          expect(Project.last.status).to eq 'executing'
          expect(Project.last.project_type).to eq 'outsourcing'
          expect(Project.last.start_date).to eq 1.day.ago.to_date
          expect(Project.last.end_date).to eq 1.day.from_now.to_date
          expect(Project.last.value).to eq 100.2
          expect(Project.last.qty_hours).to eq 300
          expect(Project.last.hour_value).to eq 200
          expect(Project.last.initial_scope).to eq 1000
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
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let(:project) { Fabricate :project, customer: customer, product: product }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: project } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
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
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let(:project) { Fabricate :project, customer: customer, product: product }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
        it 'updates the project and redirects to projects index' do
          expect(Project.last.name).to eq 'foo'
          expect(Project.last.status).to eq 'executing'
          expect(Project.last.project_type).to eq 'outsourcing'
          expect(Project.last.start_date).to eq 1.day.ago.to_date
          expect(Project.last.end_date).to eq 1.day.from_now.to_date
          expect(Project.last.value).to eq 100.2
          expect(Project.last.qty_hours).to eq 300
          expect(Project.last.hour_value).to eq 200
          expect(Project.last.initial_scope).to eq 1000
          expect(response).to redirect_to company_projects_path(company)
        end
      end

      context 'passing invalid' do
        context 'project parameters' do
          before { put :update, params: { company_id: company, id: project, project: { customer_id: customer, product_id: product, name: '', status: nil, project_type: nil, start_date: nil, end_date: nil, value: nil, qty_hours: nil, hour_value: nil, initial_scope: nil } } }
          it 'does not update the project and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:project).errors.full_messages).to eq ['Qtd de Horas não pode ficar em branco', 'Tipo do Projeto não pode ficar em branco', 'Nome não pode ficar em branco', 'Status não pode ficar em branco', 'Data de Início não pode ficar em branco', 'Data Final não pode ficar em branco', 'Escopo inicial não pode ficar em branco', 'Valor do Projeto Valor ou Valor da hora é obrigatório', 'Valor da Hora Valor ou Valor da hora é obrigatório']
          end
        end
        context 'non-existent project' do
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
  end
end
