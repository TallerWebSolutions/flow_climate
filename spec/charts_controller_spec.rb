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

    let!(:first_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, username: 'zzz' }
    let!(:second_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, username: 'aaa' }
    let!(:third_pipefy_team_config) { Fabricate :pipefy_team_config, username: 'aaa' }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }

    describe 'GET #build_operational_charts' do
      context 'passing valid parameters' do
        context 'for team' do
          let(:team) { Fabricate :team, company: company }
          let(:first_project) { Fabricate :project, customer: customer, product: product }
          let(:second_project) { Fabricate :project, customer: customer, product: product }

          let!(:first_project_result) { Fabricate :project_result, project: first_project, team: team }
          let!(:second_project_result) { Fabricate :project_result, project: second_project, team: team }

          it 'builds the operation report and respond the JS render the template' do
            get :build_operational_charts, params: { company_id: company, team_id: team.id }, xhr: true
            expect(response).to render_template 'teams/operational_charts.js.erb'
            expect(assigns(:report_data)).to be_a Highchart::OperationalChartsAdapter
            expect(assigns(:report_data).all_projects).to match_array [first_project, second_project]
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :build_operational_charts, params: { company_id: 'foo', team_id: team }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'team' do
          before { get :build_operational_charts, params: { company_id: company, team_id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :build_operational_charts, params: { company_id: company, team_id: team }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #build_strategic_charts' do
      let(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
        let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }

        let!(:first_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
        let!(:second_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
        let!(:third_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
        let!(:fourth_result) { Fabricate :project_result, project: first_project, team: team, result_date: Time.zone.today }
        let!(:fifth_result) { Fabricate :project_result, project: second_project, team: team, result_date: 1.week.from_now }

        let!(:first_demand) { Fabricate :demand, project_result: first_result, project: first_project, end_date: 3.weeks.ago }
        let!(:second_demand) { Fabricate :demand, project_result: second_result, project: first_project, end_date: 2.weeks.ago }
        let!(:third_demand) { Fabricate :demand, project_result: third_result, project: first_project, end_date: 1.week.ago }
        let!(:fourth_demand) { Fabricate :demand, project_result: fourth_result, project: first_project, end_date: 1.week.ago }
        let!(:fifth_demand) { Fabricate :demand, project_result: fifth_result, project: second_project, end_date: 1.week.ago }

        it 'builds the operation report and respond the JS render the template' do
          get :build_strategic_charts, params: { company_id: company, team_id: team }, xhr: true
          expect(response).to render_template 'teams/strategic_charts.js.erb'
          expect(assigns(:strategic_report_data).array_of_months).to eq [[Time.zone.today.month, Time.zone.today.year], [1.month.from_now.to_date.month, 1.month.from_now.to_date.year]]
          expect(assigns(:strategic_report_data).active_projects_count_data).to eq [2, 1]
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :build_strategic_charts, params: { company_id: 'foo', team_id: team.id }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'team' do
          before { get :build_strategic_charts, params: { company_id: company, team_id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :build_strategic_charts, params: { company_id: company, team_id: team.id }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #build_status_report_charts' do
      let(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        it 'builds the operation report and respond the JS render the template' do
          get :build_status_report_charts, params: { company_id: company, team_id: team.id }, xhr: true
          expect(response).to render_template 'teams/status_report_charts.js.erb'
          expect(assigns(:status_report_data)).to be_a Highchart::StatusReportChartsAdapter
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :build_status_report_charts, params: { company_id: 'foo', team_id: team.id }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'team' do
          before { get :build_status_report_charts, params: { company_id: company, team_id: 'foo' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }
          before { get :build_status_report_charts, params: { company_id: company, team_id: team.id }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
