# frozen_string_literal: true

RSpec.describe ChartsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #build_operational_charts' do
      before { get :build_operational_charts, params: { company_id: 'foo' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
    describe 'GET #build_strategic_charts' do
      before { get :build_strategic_charts, params: { company_id: 'foo' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
    describe 'GET #build_status_report_charts' do
      before { get :build_status_report_charts, params: { company_id: 'foo' }, xhr: true }
      it { expect(response.status).to eq 401 }
    end
  end

  context 'authenticated' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }
    after { travel_back }

    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }
    let(:first_team_member) { Fabricate :team_member, team: team }
    let(:second_team_member) { Fabricate :team_member, team: team }
    let(:third_team_member) { Fabricate :team_member, team: team }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }

    describe 'GET #build_operational_charts' do
      context 'passing valid parameters' do
        context 'for team' do
          let(:team) { Fabricate :team, company: company }
          let!(:first_project) { Fabricate :project, customer: customer, product: product, team: team }
          let!(:second_project) { Fabricate :project, customer: customer, product: product, team: team }

          it 'builds the operation report and respond the JS render the template' do
            get :build_operational_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true
            expect(response).to render_template 'charts/operational_charts.js.erb'
            expect(assigns(:report_data)).to be_a Highchart::OperationalChartsAdapter
            expect(assigns(:report_data).all_projects).to match_array [first_project, second_project]
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :build_operational_charts, params: { company_id: 'foo', projects_ids: team.projects.map(&:id).to_csv }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :build_operational_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #build_strategic_charts' do
      let(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        let!(:first_project) { Fabricate :project, customer: customer, product: product, team: team, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
        let!(:second_project) { Fabricate :project, customer: customer, product: product, team: team, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }

        it 'builds the operation report and respond the JS render the template' do
          get :build_strategic_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true
          expect(response).to render_template 'charts/strategic_charts.js.erb'
          expect(assigns(:strategic_chart_data).array_of_months).to eq [Time.zone.today.end_of_month, 1.month.from_now.to_date.end_of_month]
          expect(assigns(:strategic_chart_data).active_projects_count_data).to eq [2, 1]
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :build_strategic_charts, params: { company_id: 'foo', projects_ids: team.projects.map(&:id).to_csv }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :build_strategic_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #build_status_report_charts' do
      let(:team) { Fabricate :team, company: company }
      let(:customer) { Fabricate :customer, company: company }
      let!(:product) { Fabricate :product, customer: customer, team: team }

      context 'passing valid parameters' do
        context 'having projects' do
          let!(:project) { Fabricate :project, product: product }
          let!(:other_project) { Fabricate :project, product: product }
          it 'builds the status report and respond the JS render the template' do
            get :build_status_report_charts, params: { company_id: company, projects_ids: Project.all.map(&:id).to_csv }, xhr: true
            expect(response).to render_template 'charts/status_report_charts.js.erb'
            expect(assigns(:status_report_data)).to be_a Highchart::StatusReportChartsAdapter
          end
        end
        context 'having no projects' do
          it 'builds the status report with empty data' do
            get :build_status_report_charts, params: { company_id: company, projects_ids: Project.all.map(&:id).to_csv }, xhr: true
            expect(response).to render_template 'charts/status_report_charts.js.erb'
            expect(assigns(:status_report_data)).to eq({})
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :build_status_report_charts, params: { company_id: 'foo', projects_ids: team.projects.map(&:id).to_csv }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :build_status_report_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
