# frozen_string_literal: true

RSpec.describe CompaniesController, type: :controller do
  before { travel_to Time.zone.local(2018, 9, 3, 12, 20, 31) }

  after { travel_back }

  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #add_user' do
      before { patch :add_user, params: { id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #send_company_bulletin' do
      before { get :send_company_bulletin, params: { id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #update_settings' do
      before { post :update_settings, params: { id: 'xpto' }, xhr: true }

      it { expect(response.status).to eq 401 }
    end

    describe 'GET #projects_tab' do
      before { get :strategic_chart_tab, params: { id: 'xpto' }, xhr: true }

      it { expect(response.status).to eq 401 }
    end

    describe 'GET #strategic_chart_tab' do
      before { post :strategic_chart_tab, params: { id: 'xpto' }, xhr: true }

      it { expect(response.status).to eq 401 }
    end
  end

  context 'authenticated having a gold plan' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz', email_notifications: true }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    describe 'GET #index' do
      context 'passing a valid ID' do
        let(:company) { Fabricate :company, users: [user], name: 'zzz' }
        let(:other_company) { Fabricate :company, users: [user], name: 'aaa' }
        let(:out_company) { Fabricate :company }

        it 'assigns the instance variable and renders the template' do
          expect_any_instance_of(AuthenticatedController).to(receive(:user_gold_check).once.and_return(true))
          get :index
          expect(response).to render_template :index
          expect(assigns(:companies)).to eq [other_company, company]
        end
      end
    end

    describe 'GET #show' do
      context 'passing valid parameters' do
        let(:company) { Fabricate :company, users: [user] }

        context 'and the company has no settings yet' do
          let(:customer) { Fabricate :customer, company: company }

          let!(:team) { Fabricate :team, company: company, name: 'aaa' }
          let!(:other_team) { Fabricate :team, company: company, name: 'zzz' }

          let!(:finances) { Fabricate :financial_information, company: company, finances_date: 2.days.ago }
          let!(:other_finances) { Fabricate :financial_information, company: company, finances_date: Time.zone.today }

          let!(:team_member) { Fabricate :team_member, company: company, name: 'aaa', start_date: 2.weeks.ago, end_date: nil }
          let!(:other_team_member) { Fabricate :team_member, company: company, name: 'zzz', start_date: 1.week.ago, end_date: nil }
          let!(:inactive_team_member) { Fabricate :team_member, company: company, name: 'eee', start_date: 1.day.ago, end_date: Time.zone.today }

          let!(:team_resource) { Fabricate :team_resource, company: company, resource_name: 'zzz' }
          let!(:other_team_resource) { Fabricate :team_resource, company: company, resource_name: 'aaa' }

          let!(:first_project) { Fabricate :project, company: company, customers: [customer], status: :executing, start_date: Time.zone.today, end_date: Time.zone.now }
          let!(:second_project) { Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 1.month.from_now, end_date: 1.month.from_now }

          let!(:first_stage) { Fabricate :stage, company: company, teams: [team], order: 3 }
          let!(:second_stage) { Fabricate :stage, company: company, teams: [other_team], order: 2 }
          let!(:third_stage) { Fabricate :stage, company: company, teams: [team], order: 1 }

          let!(:first_account) { Fabricate :jira_account, company: company, created_at: 1.day.ago }
          let!(:second_account) { Fabricate :jira_account, company: company, created_at: 2.days.ago }

          let(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline }
          let(:second_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :backlog_growth_rate }
          let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: first_project, alert_color: :green, created_at: Time.zone.now }
          let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: first_project, alert_color: :red, created_at: 1.hour.ago }

          before { get :show, params: { id: company } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:current_user).last_company).to eq company
            expect(assigns(:financial_informations)).to match_array [other_finances, finances]
            expect(assigns(:teams)).to eq [team, other_team]
            expect(assigns(:stages_list)).to eq [third_stage, second_stage, first_stage]
            expect(assigns(:jira_accounts_list)).to eq [second_account, first_account]
            expect(assigns(:company_settings)).to be_a_new CompanySettings
            expect(assigns(:team_members)).to eq [team_member, other_team_member]
            expect(assigns(:team_resources)).to eq [other_team_resource, team_resource]
          end
        end

        context 'and the company already have settings' do
          let!(:company_settings) { Fabricate :company_settings, company: company }

          before { get :show, params: { id: company } }

          it { expect(assigns(:company_settings)).to eq company.reload.company_settings }
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent' do
          before { get :show, params: { id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #new' do
      before { get :new }

      it 'instantiates a new Company and renders the template' do
        expect(response).to render_template :new
        expect(assigns(:company)).to be_a_new Company
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company: { name: 'foo', abbreviation: 'bar' } } }

        it 'creates the new company and redirects to its show' do
          expect(Company.last.name).to eq 'foo'
          expect(Company.last.abbreviation).to eq 'bar'
          expect(Company.last.users).to eq [user]
          expect(response).to redirect_to company_path(Company.last)
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company: { name: '' } } }

        it 'does not create the company and re-render the template with the errors' do
          expect(Company.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:company).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Sigla não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:other_user) { Fabricate :user, first_name: 'aaa' }
      let(:company) { Fabricate :company }

      let!(:user_company_role) { Fabricate :user_company_role, company: company, user: user }
      let!(:other_user_company_role) { Fabricate :user_company_role, company: company, user: other_user }

      context 'valid parameters' do
        before { get :edit, params: { id: company } }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:users_in_company)).to eq [other_user_company_role, user_company_role]
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:no_user_company) { Fabricate :company, users: [] }

            before { get :edit, params: { id: no_user_company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid parameters' do
        before { put :update, params: { id: company, company: { name: 'foo', abbreviation: 'bar' } } }

        it 'updates the company and redirects to projects index' do
          expect(Company.last.name).to eq 'foo'
          expect(Company.last.abbreviation).to eq 'bar'
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'company parameters' do
          before { put :update, params: { id: company, company: { name: '', abbreviation: '' } } }

          it 'does not update the company and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:company).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Sigla não pode ficar em branco']
          end
        end

        context 'non-existent company' do
          before { put :update, params: { id: 'foo', product: { name: 'foo', abbreviation: 'bar' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { id: company, product: { name: 'foo', abbreviation: 'bar' } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #add_user' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:other_user) { Fabricate :user }

      context 'passing valid parameters' do
        context 'and the user is not in the company users list' do
          before { patch :add_user, params: { id: company, user_email: other_user.email } }

          it 'adds the user and redirects to the edit page' do
            expect(company.reload.users).to match_array [user, other_user]
            expect(response).to redirect_to edit_company_path(company)
          end
        end

        context 'and the user is already in the company users list' do
          before { patch :add_user, params: { id: company, user_email: user.email } }

          it 'does not add the repeated user' do
            expect(company.reload.users).to eq [user]
            expect(response).to redirect_to edit_company_path(company)
          end
        end
      end

      context 'passing invalid' do
        context 'non-existent company' do
          before { patch :add_user, params: { id: 'foo', user_email: user.email } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { id: company, user_email: user.email } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #send_company_bulletin' do
      let(:other_user) { Fabricate :user }
      let(:company) { Fabricate :company, users: [user, other_user] }

      context 'valid parameters' do
        context 'with notifications enabled' do
          it 'assigns the instance variables and renders the template' do
            expect(UserNotifierMailer).to receive(:company_weekly_bulletin).with(User.where(id: user.id), company).once.and_call_original
            get :send_company_bulletin, params: { id: company }
            expect(response).to redirect_to company_path(company)
            expect(flash[:notice]).to eq I18n.t('companies.send_company_bulletin.sent')
            expect(assigns(:company)).to eq company
          end
        end

        context 'without notifications enabled' do
          it 'assigns the instance variables and renders the template' do
            user.update(email_notifications: false)

            expect(UserNotifierMailer).to receive(:company_weekly_bulletin).with(User.where(id: user.id), company).once.and_call_original
            get :send_company_bulletin, params: { id: company }
            expect(response).to redirect_to company_path(company)
            expect(flash[:notice]).to be_nil
            expect(flash[:error]).to eq I18n.t('companies.send_company_bulletin.error')
            expect(assigns(:company)).to eq company
          end
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :send_company_bulletin, params: { id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :send_company_bulletin, params: { id: company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #update_settings' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid parameters' do
        context 'when the company does not have settings yet' do
          before { post :update_settings, params: { id: company, company_settings: { max_active_parallel_projects: 100, max_flow_pressure: 2.2 } }, xhr: true }

          it 'updates the already existent settings' do
            expect(company.reload.company_settings.max_active_parallel_projects).to eq 100
            expect(company.reload.company_settings.max_flow_pressure).to eq 2.2
            expect(CompanySettings.count).to eq 1
            expect(response).to render_template 'companies/update_settings.js.erb'
          end
        end

        context 'when the company already has settings' do
          let!(:company_settings) { Fabricate :company_settings, company: company }

          before { post :update_settings, params: { id: company, company_settings: { max_active_parallel_projects: 100, max_flow_pressure: 2.2 } }, xhr: true }

          it 'updates the already existent settings' do
            expect(company.reload.company_settings.max_active_parallel_projects).to eq 100
            expect(company.reload.company_settings.max_flow_pressure).to eq 2.2
            expect(response).to render_template 'companies/update_settings.js.erb'
          end
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { post :update_settings, params: { id: 'foo', company_settings: { max_active_parallel_projects: 100, max_flow_pressure: 2.2 } }, xhr: true }

            it { expect(response.status).to eq 404 }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { post :update_settings, params: { id: company, company_settings: { max_active_parallel_projects: 100, max_flow_pressure: 2.2 } }, xhr: true }

            it { expect(response.status).to eq 404 }
          end
        end
      end
    end

    describe 'GET #projects_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'having data' do
        let!(:first_project) { Fabricate :project, company: company, customers: [customer], start_date: 2.weeks.ago, end_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, company: company, customers: [customer], start_date: 3.weeks.ago, end_date: 1.day.from_now }

        context 'passing valid parameters' do
          it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
            get :projects_tab, params: { id: company }, xhr: true
            expect(response).to render_template 'projects/projects_tab'
            expect(assigns(:projects)).to eq [second_project, first_project]
            expect(assigns(:projects_summary)).to be_a ProjectsSummaryData
          end
        end
      end

      context 'having no data' do
        it 'returns empty data set' do
          get :projects_tab, params: { id: company }, xhr: true
          expect(response).to render_template 'projects/projects_tab'
          expect(assigns(:projects)).to eq []
        end
      end
    end

    describe 'GET #strategic_chart_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'having data' do
        let!(:first_project) { Fabricate :project, customers: [customer], start_date: 2.weeks.ago, end_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, customers: [customer], start_date: 3.weeks.ago, end_date: 1.day.from_now }

        context 'passing valid parameters' do
          it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
            get :strategic_chart_tab, params: { id: company }, xhr: true
            expect(response).to render_template 'charts/strategic_charts.js.erb'
            expect(assigns(:strategic_chart_data)).to be_a Highchart::StrategicChartsAdapter
          end
        end
      end

      context 'having no data' do
        it 'returns empty data set' do
          get :strategic_chart_tab, params: { id: company }, xhr: true
          expect(response).to render_template 'charts/strategic_charts.js.erb'
          expect(assigns(:projects)).to eq []
        end
      end
    end

    describe 'GET #risks_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'having data' do
        let!(:first_project) { Fabricate :project, customers: [customer], start_date: 2.weeks.ago, end_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, customers: [customer], start_date: 3.weeks.ago, end_date: 1.day.from_now }

        context 'passing valid parameters' do
          it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
            get :risks_tab, params: { id: company }, xhr: true
            expect(response).to render_template 'companies/risks_tab.js.erb'
            expect(assigns(:strategic_chart_data)).to be_a Highchart::StrategicChartsAdapter
            expect(assigns(:projects_risk_chart_data)).to be_a Highchart::ProjectRiskChartsAdapter
          end
        end
      end

      context 'having no data' do
        it 'returns empty data set' do
          get :risks_tab, params: { id: company }, xhr: true
          expect(response).to render_template 'companies/risks_tab.js.erb'
          expect(assigns(:projects)).to eq []
        end
      end
    end
  end

  context 'authenticated having no plan' do
    let(:user) { Fabricate :user, first_name: 'zzz' }

    before { sign_in user }

    describe 'GET #index' do
      before { get :index }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #new' do
      before { get :new }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'POST #create' do
      before { post :create }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'PATCH #add_user' do
      before { patch :add_user, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #send_company_bulletin' do
      before { get :send_company_bulletin, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'POST #update_settings' do
      before { post :update_settings, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #projects_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      before { get :projects_tab, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #strategic_chart_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      before { get :strategic_chart_tab, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end
  end

  context 'authenticated having a lite plan' do
    let(:plan) { Fabricate :plan, plan_type: :lite }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    describe 'GET #index' do
      before { get :index }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #new' do
      before { get :new }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'POST #create' do
      before { post :create }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'PATCH #add_user' do
      before { patch :add_user, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #send_company_bulletin' do
      before { get :send_company_bulletin, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'POST #update_settings' do
      before { post :update_settings, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #projects_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      before { get :projects_tab, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #strategic_chart_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      before { get :strategic_chart_tab, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end
  end

  context 'authenticated having a trial plan' do
    let(:plan) { Fabricate :plan, plan_type: :trial }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    describe 'GET #index' do
      before { get :index }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #new' do
      before { get :new }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'POST #create' do
      before { post :create }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'PATCH #add_user' do
      before { patch :add_user, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #send_company_bulletin' do
      before { get :send_company_bulletin, params: { id: 'foo' } }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'POST #update_settings' do
      before { post :update_settings, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #projects_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      before { get :projects_tab, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end

    describe 'GET #strategic_chart_tab' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      before { get :strategic_chart_tab, params: { id: 'xpto' }, xhr: true }

      it 'redirects to the user profile with an alert' do
        expect(response).to redirect_to user_path(user)
        flash[:alert] = I18n.t('plans.validations.no_gold_plan')
      end
    end
  end
end
