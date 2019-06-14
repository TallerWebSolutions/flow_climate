# frozen_string_literal: true

RSpec.describe ProjectRiskConfigsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'xpto', project_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'xpto', project_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #activate' do
      before { patch :activate, params: { company_id: 'xpto', project_id: 'bar', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #deactivate' do
      before { patch :deactivate, params: { company_id: 'xpto', project_id: 'bar', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', project_id: 'xpto', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    describe 'GET #new' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:project) { Fabricate :project, customers: [customer], products: [product], end_date: 5.days.from_now }

      context 'passing valid IDs' do
        before { get :new, params: { company_id: company, project_id: project } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:project_risk_config)).to be_a_new ProjectRiskConfig
          expect(assigns(:project_risk_config).project).to eq project
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent project' do
          before { get :new, params: { company_id: company, project_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:company) { Fabricate :company, users: [user] }
      let(:team) { Fabricate :team, company: company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:project) { Fabricate :project, customers: [customer], products: [product], end_date: 2.days.from_now }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, project_risk_config: { risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 14 } } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_path(company, project)
          risk_config = ProjectRiskConfig.last
          expect(risk_config.risk_type).to eq 'no_money_to_deadline'
          expect(risk_config.low_yellow_value).to eq 10.0
          expect(risk_config.high_yellow_value).to eq 14.0
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_risk_config: { risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 14 } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_risk_config: { risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 14 } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'results parameters' do
          before { post :create, params: { company_id: company, project_id: project, project_risk_config: { risk_type: nil } } }

          it 'renders the template again showing the errors' do
            expect(response).to render_template :new
            expect(assigns(:project_risk_config).errors.full_messages).to eq ['Tipo do Risco não pode ficar em branco', 'Maior Valor do Amarelo não pode ficar em branco', 'Menor Valor do Amarelo não pode ficar em branco']
          end
        end
      end
    end

    describe 'PATCH #activate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:team) { Fabricate :team, company: company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:project) { Fabricate :project, customers: [customer], products: [product], end_date: 2.days.from_now }
      let(:project_risk_config) { Fabricate :project_risk_config, project: project, active: false }

      context 'passing valid parameters' do
        before { patch :activate, params: { company_id: company, project_id: project, id: project_risk_config } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_path(company, project)
          expect(project_risk_config.reload.active).to be true
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { patch :activate, params: { company_id: 'foo', project_id: project, id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { patch :activate, params: { company_id: company, project_id: 'foo', id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #deactivate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:team) { Fabricate :team, company: company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:project) { Fabricate :project, customers: [customer], products: [product], end_date: 2.days.from_now }
      let(:project_risk_config) { Fabricate :project_risk_config, project: project, active: true }

      context 'passing valid parameters' do
        before { patch :deactivate, params: { company_id: company, project_id: project, id: project_risk_config } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_path(company, project)
          expect(project_risk_config.reload.active).to be false
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { patch :deactivate, params: { company_id: 'foo', project_id: project, id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { patch :deactivate, params: { company_id: company, project_id: 'foo', id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let!(:project_risk_config) { Fabricate :project_risk_config, project: project }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, project_id: project, id: project_risk_config } }

          it 'deletes the project result and redirects' do
            expect(response).to redirect_to company_project_path(company, project)
            expect(ProjectRiskConfig.last).to be_nil
          end
        end

        context 'having dependencies' do
          let!(:project_risk_config) { Fabricate :project_risk_config, project: project }
          let!(:project_risk_alert) { Fabricate :project_risk_alert, project: project, project_risk_config: project_risk_config }

          before { delete :destroy, params: { company_id: company, project_id: project, id: project_risk_config } }

          it 'does not delete the project and show the error' do
            expect(response).to redirect_to company_project_path(company, project)
            expect(Project.last).to eq project
            expect(flash[:error]).to eq assigns(:project_risk_config).errors.full_messages.join(',')
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent project result' do
          before { delete :destroy, params: { company_id: company, project_id: project, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, project_id: 'foo', id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', project_id: project, id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, project_id: project, id: project_risk_config } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
