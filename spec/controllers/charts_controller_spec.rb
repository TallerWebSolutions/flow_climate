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

    describe 'GET #statistics_charts' do
      before { get :statistics_charts, params: { company_id: 'foo' }, xhr: true }

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
    let(:product) { Fabricate :product, customer: customer }

    describe 'GET #build_operational_charts' do
      context 'passing valid parameters' do
        context 'with projects' do
          let(:team) { Fabricate :team, company: company }
          let!(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team }
          let!(:second_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team }

          it 'builds the operation and status report and respond the JS render the template' do
            get :build_operational_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true
            expect(response).to render_template 'charts/operational_charts'
            expect(assigns(:report_data)).to be_a Highchart::OperationalChartsAdapter
            expect(assigns(:status_report_data)).to be_a Highchart::StatusReportChartsAdapter
            expect(assigns(:report_data).all_projects).to match_array [first_project, second_project]
          end
        end

        context 'without projects' do
          it 'builds empty operation and status report and respond the JS render the template' do
            get :build_operational_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true
            expect(response).to render_template 'charts/operational_charts'
            expect(assigns(:status_report_data)).to eq({})
            expect(assigns(:report_data)).to eq({})
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
        let!(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: Time.zone.yesterday, end_date: 10.days.from_now }
        let!(:second_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: Time.zone.yesterday, end_date: 50.days.from_now }

        it 'builds the operation report and respond the JS render the template' do
          get :build_strategic_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).to_csv }, xhr: true
          expect(response).to render_template 'charts/strategic_charts'
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

    describe 'GET #statistics_charts' do
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }

      context 'having projects' do
        let!(:first_project) { Fabricate :project, company: company, customers: [customer], team: team, start_date: 2.weeks.ago, end_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, company: company, customers: [customer], team: team, start_date: 3.weeks.ago, end_date: 1.day.from_now }

        let!(:other_project) { Fabricate :project, company: company, customers: [customer], team: other_team, start_date: 3.weeks.ago, end_date: 1.day.from_now }

        let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.days.ago, end_date: Time.zone.now, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
        let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 1.day.ago, end_date: Time.zone.now, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
        let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: Time.zone.now, effort_downstream: 100, effort_upstream: 20 }

        let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: 2.days.ago, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
        let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: 14.days.ago, end_date: 2.days.ago, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
        let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: 7.days.ago, end_date: 3.days.ago, effort_downstream: 100, effort_upstream: 20 }
        let!(:seventh_demand) { Fabricate :demand, project: other_project, commitment_date: 7.days.ago, end_date: 3.days.ago, effort_downstream: 100, effort_upstream: 20 }

        let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true }
        let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 2.days.ago }
        let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 4.days.ago }
        let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
        let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
        let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

        context 'with projects consolidations' do
          let!(:project_consolidation) { Fabricate :project_consolidation, consolidation_date: Time.zone.today, project: first_project }
          let!(:other_project_consolidation) { Fabricate :project_consolidation, consolidation_date: 1.week.ago, project: second_project }

          context 'passing valid parameters' do
            context 'no start nor end dates nor period provided' do
              context 'and the project started after 3 months ago' do
                it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
                  get :statistics_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).join(','), project_status: '' }, xhr: true
                  expect(response).to render_template 'charts/statistics_tab'
                  expect(response).to render_template 'charts/_statistics_charts'

                  expect(assigns(:start_date)).to eq Date.new(2018, 3, 16)
                  expect(assigns(:end_date)).to eq Date.new(2018, 4, 7)
                  expect(assigns(:period)).to eq 'month'
                  expect(assigns(:leadtime_confidence)).to eq 80

                  expect(assigns(:project_statistics_data).scope_data).to eq [{ data: [64, 66], marker: { enabled: true }, name: I18n.t('projects.general.scope') }]
                  expect(assigns(:project_statistics_data).leadtime_data).to eq [{ data: [0, 7.0], marker: { enabled: true }, name: I18n.t('projects.general.leadtime', percentil: 80) }]
                  expect(assigns(:project_statistics_data).block_data).to eq [{ data: [0, 6], marker: { enabled: true }, name: I18n.t('projects.statistics.accumulated_blocks.data_title') }]

                  expect(assigns(:portfolio_statistics_data).block_by_project_variation).to eq 0.0
                  expect(assigns(:portfolio_statistics_data).block_by_project_data).to eq [{ data: [6], marker: { enabled: true }, name: I18n.t('portfolio.charts.block_count') }]
                  expect(assigns(:portfolio_statistics_data).block_by_project_x_axis).to eq [first_project.name]
                  expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:x_axis]).to eq [1.week.ago.to_date, Time.zone.today]
                  expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:y_axis][0][:name]).to eq I18n.t('charts.lead_time_data_range_evolution.total_range')
                  expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:y_axis][0][:data]).to eq [1.3888888888888888e-05, 1.3888888888888888e-05]
                end
              end

              context 'and the project started before 3 months ago' do
                let!(:first_project) { Fabricate :project, customers: [customer], team: team, start_date: 4.months.ago.to_date, end_date: Time.zone.today }

                it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
                  get :statistics_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).join(','), project_status: '' }, xhr: true

                  expect(assigns(:start_date)).to eq 3.months.ago.to_date
                  expect(assigns(:end_date)).to eq Date.new(2018, 4, 7)
                  expect(assigns(:period)).to eq 'month'
                  expect(assigns(:leadtime_confidence)).to eq 80
                end
              end
            end

            context 'and a start and end dates provided' do
              it 'builds the statistic adapter and renders the view using the parameters' do
                get :statistics_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).join(','), start_date: 1.week.ago, end_date: Time.zone.today, period: 'month', project_status: '' }, xhr: true
                expect(response).to render_template 'charts/statistics_tab'
                expect(response).to render_template 'charts/_statistics_charts'

                expect(assigns(:project_statistics_data).scope_data).to eq [{ data: [64, 66], marker: { enabled: true }, name: I18n.t('projects.general.scope') }]
                expect(assigns(:project_statistics_data).leadtime_data).to eq [{ data: [0, 7.0], marker: { enabled: true }, name: I18n.t('projects.general.leadtime', percentil: 80) }]
                expect(assigns(:project_statistics_data).block_data).to eq [{ data: [0, 6], marker: { enabled: true }, name: I18n.t('projects.statistics.accumulated_blocks.data_title') }]

                expect(assigns(:portfolio_statistics_data).block_by_project_variation).to eq 0.0
                expect(assigns(:portfolio_statistics_data).block_by_project_data).to eq [{ data: [6], marker: { enabled: true }, name: I18n.t('portfolio.charts.block_count') }]
                expect(assigns(:portfolio_statistics_data).block_by_project_x_axis).to eq [first_project.name]

                expect(assigns(:portfolio_statistics_data).aging_by_project_variation).to eq 0.5714285714285714
                expect(assigns(:portfolio_statistics_data).aging_by_project_data).to eq [{ data: [14, 22], marker: { enabled: true }, name: I18n.t('portfolio.charts.aging_by_project.data_title') }]
                expect(assigns(:portfolio_statistics_data).aging_by_project_x_axis).to eq [first_project.name, second_project.name]

                expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:x_axis]).to eq [1.week.ago.to_date, Time.zone.today]
                expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:y_axis][0][:name]).to eq I18n.t('charts.lead_time_data_range_evolution.total_range')
                expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:y_axis][0][:data]).to eq [1.3888888888888888e-05, 1.3888888888888888e-05]
              end
            end
          end
        end

        context 'without projects consolidations' do
          it 'returns empty data set' do
            get :statistics_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).join(','), project_status: '' }, xhr: true
            expect(response).to render_template 'charts/statistics_tab'
            expect(response).to render_template 'charts/_statistics_charts'

            expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:x_axis]).to eq []
            expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:y_axis][0][:name]).to eq I18n.t('charts.lead_time_data_range_evolution.total_range')
            expect(assigns(:projects_consolidations_charts_adapter).lead_time_data_range_evolution[:y_axis][0][:data]).to eq []
          end
        end
      end

      context 'having no projects' do
        it 'returns empty data set' do
          get :statistics_charts, params: { company_id: company, projects_ids: team.projects.map(&:id).join(','), project_status: '' }, xhr: true
          expect(response).to render_template 'charts/statistics_tab'
          expect(response).to render_template 'charts/_statistics_charts'

          expect(assigns(:project_statistics_data)).to be_nil
          expect(assigns(:portfolio_statistics_data)).to be_nil

          expect(assigns(:projects_consolidations_charts_adapter)).to be_nil
        end
      end
    end
  end
end
