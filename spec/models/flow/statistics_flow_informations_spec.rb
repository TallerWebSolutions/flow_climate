# frozen_string_literal: true

RSpec.describe Flow::StatisticsFlowInformations, type: :model do
  before { travel_to Time.zone.local(2019, 5, 7, 18, 35, 0) }

  after { travel_back }

  shared_context 'demand data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let(:first_project) { Fabricate :project, customers: [customer], products: [product], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, customers: [customer], products: [product], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, customers: [customer], products: [product], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_opened_demand) { Fabricate :demand, product: product, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }
    let!(:second_opened_demand) { Fabricate :demand, product: product, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }

    let!(:first_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 21, 23, 1, 46), effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), commitment_date: Time.zone.local(2018, 3, 17, 23, 1, 46), effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46), commitment_date: nil, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, product: product, project: third_project, external_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:seventh_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'first_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 30, 10, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'second_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 25, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 44), effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'third_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 45), effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 48), effort_upstream: 56, effort_downstream: 25 }

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
  end

  describe '.initialize' do
    context 'having data' do
      include_context 'demand data'

      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns the correct information' do
        stats_flow_info = described_class.new(Demand.all)

        expect(stats_flow_info.demands).to match_array Demand.all
        expect(stats_flow_info.current_limit_date).to eq Time.zone.today.end_of_week
        expect(stats_flow_info.demands_charts_ids).to match_array %w[first_demand third_bug second_bug first_bug fourth_bug seventh_demand third_demand second_demand sixth_demand]
        expect(stats_flow_info.lead_time_bins).to eq [73.75, 220.18, 366.6]
        expect(stats_flow_info.lead_time_95p).to eq 430.21474537037034
        expect(stats_flow_info.lead_time_80p).to eq 390.0147453703704
        expect(stats_flow_info.lead_time_65p).to eq 190.9705833333333
        expect(stats_flow_info.lead_time_histogram_data).to eq [5.0, 1.0, 3.0]
        expect(stats_flow_info.lead_time_data_array).to match_array [0.5416666666666666, 0.999988425925926, 1.000023148148148, 4.9999768518518515, 7.755694444444444, 236.77430555555554, 372.81474537037036, 415.81474537037036, 439.81474537037036]

        stats_flow_info.statistics_flow_behaviour(dates_array.first)
        expect(stats_flow_info.average_aging_per_period).to eq [0]
        expect(stats_flow_info.lead_time_accumulated).to eq [0]

        stats_flow_info.statistics_flow_behaviour(dates_array.second)
        expect(stats_flow_info.average_aging_per_period).to eq [0, 36.79736111111111]
        expect(stats_flow_info.lead_time_accumulated).to eq [0, 7.755694444444444]
      end
    end

    context 'having no data' do
      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'initializes empty attributes' do
        stats_flow_info = described_class.new(Demand.all)

        expect(stats_flow_info.demands).to eq []
        expect(stats_flow_info.current_limit_date).to eq Time.zone.today.end_of_week
        expect(stats_flow_info.lead_time_bins).to eq []
        expect(stats_flow_info.lead_time_histogram_data).to eq []
        expect(stats_flow_info.demands_charts_ids).to eq []
        expect(stats_flow_info.lead_time_data_array).to eq []
        expect(stats_flow_info.lead_time_95p).to eq 0
        expect(stats_flow_info.lead_time_80p).to eq 0
        expect(stats_flow_info.lead_time_65p).to eq 0

        stats_flow_info.statistics_flow_behaviour(dates_array.first)
        expect(stats_flow_info.average_aging_per_period).to eq []
        expect(stats_flow_info.lead_time_accumulated).to eq []
      end
    end
  end
end
