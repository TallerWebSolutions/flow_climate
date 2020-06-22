# frozen_string_literal: true

RSpec.describe Highchart::StatusReportChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    shared_context 'demands data' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }

      let(:team) { Fabricate :team, company: company }

      let(:first_project) { Fabricate :project, team: team, customers: [customer], products: [product], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10 }
      let(:second_project) { Fabricate :project, team: team, customers: [customer], products: [product], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10 }
      let(:third_project) { Fabricate :project, team: team, customers: [customer], products: [product], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10 }

      let(:queue_ongoing_stage) { Fabricate :stage, teams: [team], company: company, stage_stream: :downstream, queue: false, name: 'queue_stage' }
      let(:touch_ongoing_stage) { Fabricate :stage, teams: [team], company: company, stage_stream: :downstream, queue: true, name: 'ongoing_stage' }

      let(:first_stage) { Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true, name: 'first_stage' }
      let(:second_stage) { Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true, name: 'second_stage' }
      let(:third_stage) { Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true, name: 'third_stage' }
      let(:fourth_stage) { Fabricate :stage, company: company, teams: [team], stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true, name: 'fourth_stage' }
      let(:fifth_stage) { Fabricate :stage, company: company, teams: [team], stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true, name: 'fifth_stage' }

      let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
      let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

      let!(:first_opened_demand) { Fabricate :demand, product: product, project: first_project, team: team, demand_title: 'first_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }
      let!(:second_opened_demand) { Fabricate :demand, product: product, project: first_project, team: team, demand_title: 'second_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }

      let!(:first_demand) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 21, 23, 1, 46), effort_upstream: 12, effort_downstream: 20 }
      let!(:third_demand) { Fabricate :demand, product: product, project: second_project, team: team, external_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), commitment_date: Time.zone.local(2018, 3, 17, 23, 1, 46), effort_upstream: 27, effort_downstream: 40 }
      let!(:fourth_demand) { Fabricate :demand, product: product, project: second_project, team: team, external_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46), commitment_date: nil, effort_upstream: 80, effort_downstream: 34 }
      let!(:fifth_demand) { Fabricate :demand, product: product, project: third_project, team: team, external_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, effort_upstream: 56, effort_downstream: 25 }
      let!(:sixth_demand) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
      let!(:seventh_demand) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, effort_upstream: 56, effort_downstream: 25 }

      let!(:first_bug) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'first_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 30, 10, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
      let!(:second_bug) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'second_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 25, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
      let!(:third_bug) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'third_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
      let!(:fourth_bug) { Fabricate :demand, product: product, project: first_project, team: team, external_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }

      let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
      let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
      let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
      let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: fourth_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
      let!(:fifth_item_assignment) { Fabricate :item_assignment, demand: fifth_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
      let!(:sixth_item_assignment) { Fabricate :item_assignment, demand: sixth_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
      let!(:seventh_item_assignment) { Fabricate :item_assignment, demand: seventh_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }

      let!(:queue_ongoing_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 14, 17, 9, 58) }
      let!(:touch_ongoing_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 14, 17, 9, 58) }

      let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58) }
      let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 2, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 10, 17, 9, 58) }
      let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 4, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 20, 17, 9, 58) }
      let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: fourth_demand, last_time_in: Time.zone.local(2018, 1, 8, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 2, 17, 9, 58) }
      let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 3, 8, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 2, 17, 9, 58) }
      let!(:sixth_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 4, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 25, 17, 9, 58) }
      let!(:seventh_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 3, 25, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 4, 17, 9, 58) }
      let!(:eigth_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 3, 30, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 4, 17, 9, 58) }

      let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.local(2018, 2, 27, 17, 30, 58), unblock_time: Time.zone.local(2018, 2, 28, 17, 9, 58), active: true }
      let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 30.hours.ago }
      let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 1.day.ago }
      let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
      let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
      let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

      let(:start_date) { Project.all.map(&:start_date).min }
      let(:end_date) { Project.all.map(&:end_date).max }
    end

    describe '.initialize' do
      context 'with projects' do
        include_context 'demands data'
        subject(:report_data) { described_class.new(Demand.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

        it 'do the math and provides the correct information' do
          travel_to Time.zone.local(2018, 5, 1, 10, 0, 0) do
            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 25), Date.new(2018, 3, 4), Date.new(2018, 3, 11), Date.new(2018, 3, 18), Date.new(2018, 3, 25), Date.new(2018, 4, 1), Date.new(2018, 4, 8), Date.new(2018, 4, 15), Date.new(2018, 4, 22), Date.new(2018, 4, 29), Date.new(2018, 5, 6), Date.new(2018, 5, 13)]
            expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [42] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [5] }])
            expect(report_data.dates_to_montecarlo_duration).not_to be_empty
            expect(report_data.confidence_95_duration).to be_within(5).of(100)
            expect(report_data.confidence_80_duration).to be_within(5).of(82)
            expect(report_data.confidence_60_duration).to be_within(5).of(69)
            expect(report_data.deadline).to eq [{ data: [13], name: I18n.t('projects.index.total_remaining_days') }, { color: '#F45830', data: [71], name: I18n.t('projects.index.passed_time') }]
            expect(report_data.cumulative_flow_diagram_downstream).to match_array([{ name: 'queue_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'ongoing_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'first_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'second_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }, { name: 'third_stage', data: [3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6] }])
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
  end
end
