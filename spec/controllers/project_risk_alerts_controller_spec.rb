# frozen_string_literal: true

RSpec.describe ProjectRiskAlertsController do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { put :index, params: { company_id: 'xpto', project_id: 'bar' } }

      it { expect(response).to redirect_to new_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }

    before { login_as user }

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let!(:project_risk_alert) { Fabricate :project_risk_alert, project: project, created_at: 1.day.ago }
      let!(:other_project_risk_alert) { Fabricate :project_risk_alert, project: project, created_at: Time.zone.now }

      context 'passing valid parameters' do
        before { get :index, params: { company_id: company, project_id: project } }

        it 'assigns the instance variable and renders the template' do
          expect(project).to eq project
          expect(company).to eq company
          expect(assigns(:project_risk_alerts)).to eq [other_project_risk_alert, project_risk_alert]
          expect(response).to render_template 'project_risk_alerts/index'
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :index, params: { company_id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { get :index, params: { company_id: company, project_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
