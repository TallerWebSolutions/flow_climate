# frozen_string_literal: true

RSpec.describe Highchart::StatusReportChartsAdapter, type: :data_object do
  context 'with projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    describe '.initialize' do
      context 'with projects' do
        it 'does the math and provides the correct information' do
          travel_to Time.zone.local(2018, 5, 1, 10, 0, 0) do
            product = Fabricate :product, customer: customer
            team = Fabricate :team, company: company

            first_project = Fabricate :project, team: team, customers: [customer], products: [product], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10
            second_project = Fabricate :project, team: team, customers: [customer], products: [product], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10
            third_project = Fabricate :project, team: team, customers: [customer], products: [product], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10

            queue_ongoing_stage = Fabricate :stage, teams: [team], company: company, stage_stream: :downstream, queue: false, name: 'queue_stage'
            touch_ongoing_stage = Fabricate :stage, teams: [team], company: company, stage_stream: :downstream, queue: true, name: 'ongoing_stage'

            first_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true, name: 'first_stage'
            second_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true, name: 'second_stage'
            third_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true, name: 'third_stage'
            fourth_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true, name: 'fourth_stage'
            fifth_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true, name: 'fifth_stage'

            Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10
            Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10

            Fabricate :demand, product: product, project: first_project, team: team, demand_title: 'first_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil
            Fabricate :demand, product: product, project: first_project, team: team, demand_title: 'second_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil

            first_demand = Fabricate :demand, product: product, project: first_project, team: team, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5
            second_demand = Fabricate :demand, product: product, project: first_project, team: team, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 21, 23, 1, 46), effort_upstream: 12, effort_downstream: 20
            third_demand = Fabricate :demand, product: product, project: second_project, team: team, external_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), commitment_date: Time.zone.local(2018, 3, 17, 23, 1, 46), effort_upstream: 27, effort_downstream: 40
            fourth_demand = Fabricate :demand, product: product, project: second_project, team: team, external_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46), commitment_date: nil, effort_upstream: 80, effort_downstream: 34
            fifth_demand = Fabricate :demand, product: product, project: third_project, team: team, external_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, effort_upstream: 56, effort_downstream: 25
            sixth_demand = Fabricate :demand, product: product, project: first_project, team: team, external_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), effort_upstream: 56, effort_downstream: 25
            Fabricate :demand, product: product, project: first_project, team: team, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, effort_upstream: 56, effort_downstream: 25

            Fabricate :demand, product: product, project: first_project, team: team, external_id: 'first_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 30, 10, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25
            Fabricate :demand, product: product, project: first_project, team: team, external_id: 'second_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 25, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25
            Fabricate :demand, product: product, project: first_project, team: team, external_id: 'third_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25
            Fabricate :demand, product: product, project: first_project, team: team, external_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25

            Fabricate :demand_transition, stage: queue_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 14, 17, 9, 58)
            Fabricate :demand_transition, stage: touch_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 14, 17, 9, 58)

            Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58)
            Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 2, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 10, 17, 9, 58)
            Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 4, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 20, 17, 9, 58)
            Fabricate :demand_transition, stage: fourth_stage, demand: fourth_demand, last_time_in: Time.zone.local(2018, 1, 8, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 2, 17, 9, 58)
            Fabricate :demand_transition, stage: fifth_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 3, 8, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 2, 17, 9, 58)
            Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 4, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 25, 17, 9, 58)
            Fabricate :demand_transition, stage: queue_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 3, 25, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 4, 17, 9, 58)
            Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 3, 30, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 4, 17, 9, 58)

            report_data = described_class.new(Demand.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week')

            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 25), Date.new(2018, 3, 4), Date.new(2018, 3, 11), Date.new(2018, 3, 18), Date.new(2018, 3, 25), Date.new(2018, 4, 1), Date.new(2018, 4, 8), Date.new(2018, 4, 15), Date.new(2018, 4, 22), Date.new(2018, 4, 29), Date.new(2018, 5, 6), Date.new(2018, 5, 13)]
            expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [29] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [10] }])
            expect(report_data.deadline).to eq [{ data: [13], name: I18n.t('projects.index.total_remaining_days') }, { color: '#F45830', data: [71], name: I18n.t('projects.index.passed_time') }]
            expect(report_data.cumulative_flow_diagram_downstream).to match_array([{ name: 'queue_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'ongoing_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'first_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'second_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'third_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }])
          end
        end
      end
    end
  end

  context 'with no projects' do
    subject(:report_data) { described_class.new(Project.none, 1.month.ago, Time.zone.now, 'week') }

    it 'return empty sets' do
      expect(report_data.all_projects).to eq []
      expect(report_data.x_axis).to eq []
      expect(report_data.hours_burnup_per_week_data).to be_nil
    end
  end
end
