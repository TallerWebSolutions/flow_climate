# frozen_string_literal: true

RSpec.describe ChartsController do
  context 'unauthenticated' do
    describe 'GET #build_strategic_charts' do
      before { get :build_strategic_charts, params: { company_id: 'foo' }, xhr: true }

      it { expect(response).to redirect_to new_session_path }
    end
  end

  context 'authenticated' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    let(:user) { Fabricate :user }
    before { login_as user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }
    let(:first_team_member) { Fabricate :team_member, teams: [team] }
    let(:second_team_member) { Fabricate :team_member, teams: [team] }
    let(:third_team_member) { Fabricate :team_member, teams: [team] }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

    describe 'GET #build_strategic_charts' do
      let(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        let!(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 2.months.ago, end_date: 1.month.from_now }
        let!(:second_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 1.month.ago, end_date: 2.months.from_now }
        let!(:third_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :finished, start_date: 3.months.ago, end_date: 1.month.ago }

        let!(:first_demand) { Fabricate :demand, product: product, project: first_project, created_date: 4.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago }
        let!(:second_demand) { Fabricate :demand, product: product, project: first_project, created_date: 1.day.ago, commitment_date: 1.day.ago, end_date: 1.day.ago }
        let!(:third_demand) { Fabricate :demand, product: product, project: second_project, created_date: 7.days.ago, commitment_date: 7.days.ago, end_date: Time.zone.now }
        let!(:fourth_demand) { Fabricate :demand, product: product, project: third_project, created_date: 7.days.ago, commitment_date: 7.days.ago, end_date: Time.zone.now }

        it 'builds the operation report and respond the JS render the template' do
          get :build_strategic_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv, teams_ids: team.id }, xhr: true

          expect(response).to render_template 'charts/strategic_charts'
          expect(assigns(:strategic_chart_data).x_axis).to eq TimeService.instance.months_between_of(3.months.ago.to_date.end_of_month, 2.months.from_now.end_of_month)
          expect(assigns(:strategic_chart_data).active_projects_count_data).to eq [1, 1, 2, 0, 1, 1]
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
  end
end
