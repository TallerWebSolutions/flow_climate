# frozen_string_literal: true

RSpec.describe Flow::WorkItemFlowInformation do
  let(:company) { Fabricate :company }
  let(:team) { Fabricate :team }

  let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, company: company, customer: customer }

  describe '.initialize' do
    context 'with data' do
      it 'assigns the correct information' do
        travel_to Time.zone.local(2018, 4, 30, 18, 30, 0) do
          first_project = Fabricate :project, products: [product], customers: [customer], status: :executing, name: 'first_project', start_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 3, 22), qty_hours: 1000, initial_scope: 10
          second_project = Fabricate :project, products: [product], customers: [customer], status: :waiting, name: 'second_project', start_date: Date.new(2018, 1, 4), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10
          third_project = Fabricate :project, products: [product], customers: [customer], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 1, 7), end_date: Date.new(2018, 4, 13), qty_hours: 800, initial_scope: 10
          dates_array = TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max)

          first_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, commitment_point: false, end_point: false, order: 0
          second_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, commitment_point: true, end_point: false, order: 1
          third_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, commitment_point: false, end_point: false, order: 2
          fourth_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, commitment_point: false, end_point: false, order: 3
          fifth_stage = Fabricate :stage, company: company, teams: [team], stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, commitment_point: false, end_point: true, order: 4

          Fabricate :demand, product: product, team: team, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil
          Fabricate :demand, product: product, team: team, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil

          first_demand = Fabricate :demand, product: product, team: team, project: first_project, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), demand_tags: %w[aaa ccc sbbrubles]
          second_demand = Fabricate :demand, product: product, team: team, project: first_project, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), demand_tags: %w[sbbrubles]
          third_demand = Fabricate :demand, product: product, team: team, project: second_project, external_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), demand_tags: %w[ccc]
          fourth_demand = Fabricate :demand, product: product, team: team, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46)
          fifth_demand = Fabricate :demand, product: product, team: team, project: third_project, external_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46)
          Fabricate :demand, product: product, team: team, project: first_project, external_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46)
          Fabricate :demand, product: product, team: team, project: first_project, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months

          first_bug = Fabricate :demand, product: product, team: team, project: first_project, external_id: 'first_bug', work_item_type: bug_type, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46)
          Fabricate :demand, product: product, team: team, project: first_project, external_id: 'second_bug', work_item_type: bug_type, created_date: Time.zone.local(2018, 2, 15, 23, 1, 46)
          Fabricate :demand, product: product, team: team, project: first_project, external_id: 'third_bug', work_item_type: bug_type, created_date: Time.zone.local(2018, 3, 15, 23, 1, 46)
          Fabricate :demand, product: product, team: team, project: first_project, external_id: 'fourth_bug', work_item_type: bug_type, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46)

          Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 28, 17, 9, 58)
          Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 28, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 29, 17, 9, 58)
          Fabricate :demand_transition, stage: third_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 29, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 1, 17, 9, 58)
          Fabricate :demand_transition, stage: fourth_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 1, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58)
          Fabricate :demand_transition, stage: fifth_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 2, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 3, 17, 9, 58)

          Fabricate :demand_transition, stage: first_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 28, 17, 9, 58)
          Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 2, 28, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 29, 17, 9, 58)
          Fabricate :demand_transition, stage: third_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 2, 29, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 1, 17, 9, 58)
          Fabricate :demand_transition, stage: fourth_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 3, 1, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58)
          Fabricate :demand_transition, stage: fifth_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 3, 2, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 3, 17, 9, 58)

          Fabricate :demand_transition, stage: first_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 28, 17, 9, 58)
          Fabricate :demand_transition, stage: second_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 2, 28, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 29, 17, 9, 58)
          Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 2, 29, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 1, 17, 9, 58)
          Fabricate :demand_transition, stage: fourth_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 3, 1, 17, 9, 59), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58)
          Fabricate :demand_transition, stage: fifth_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 1, 20, 17, 9, 59)

          Fabricate :demand_transition, stage: first_stage, demand: fourth_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 28, 17, 9, 58)
          Fabricate :demand_transition, stage: second_stage, demand: fourth_demand, last_time_in: Time.zone.local(2018, 2, 28, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 29, 17, 9, 58)
          Fabricate :demand_transition, stage: third_stage, demand: fourth_demand, last_time_in: Time.zone.local(2018, 2, 29, 17, 9, 59)

          Fabricate :demand_transition, stage: first_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 1, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 1, 30, 17, 9, 58)
          Fabricate :demand_transition, stage: second_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 2, 1, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 3, 17, 9, 58)
          Fabricate :demand_transition, stage: third_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 2, 5, 17, 9, 59), last_time_out: Time.zone.local(2018, 2, 8, 17, 9, 58)
          Fabricate :demand_transition, stage: fourth_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 2, 8, 17, 9, 59)

          Fabricate :demand_transition, stage: fifth_stage, demand: first_bug, last_time_in: Time.zone.local(2018, 2, 2, 17, 9, 59)

          item_flow_info = described_class.new(Demand.all, 10, dates_array.length, dates_array.last, 'week')
          expect(item_flow_info.demands).to match_array Demand.all
          expect(item_flow_info.uncertain_scope).to eq 10
          expect(item_flow_info.current_scope).to eq 22
          expect(item_flow_info.period_size).to eq 15

          item_flow_info.work_items_flow_behaviour(dates_array.first, dates_array.first, 0, true)

          expect(item_flow_info.demands_tags_hash.to_h).to eq({ 'ccc' => 2, 'sbbrubles' => 2, 'aaa' => 1 })
          dates_array.each do |date|
            add_data_to_chart = date < Time.zone.now.end_of_week
            item_flow_info.work_items_flow_behaviour(dates_array.first, date, 1, add_data_to_chart)
            item_flow_info.build_cfd_hash(dates_array.first, date)
          end

          expect(item_flow_info.scope_per_period).to eq [10, 10, 10, 16, 16, 17, 17, 19, 21, 21, 21, 22, 22, 22, 22, 22]
          expect(item_flow_info.ideal_per_period).to eq [1.4666666666666666, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333, 2.933333333333333]
          expect(item_flow_info.throughput_per_period).to eq [0, 0, 0, 0, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0]
          expect(item_flow_info.accumulated_throughput).to eq [0, 0, 0, 0, 0, 1, 1, 2, 2, 4, 4, 4, 4, 4, 4, 4]
          expect(item_flow_info.accumulated_bugs_opened_data_array).to eq [0, 0, 0, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4]
          expect(item_flow_info.accumulated_bugs_closed_data_array).to eq [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
          expect(item_flow_info.bugs_opened_data_array).to eq [0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0]
          expect(item_flow_info.bugs_closed_data_array).to eq [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          expect(item_flow_info.bugs_share_data_array).to eq [0, 0, 0, 33.33333333333333, 33.33333333333333, 28.57142857142857, 28.57142857142857, 33.33333333333333, 27.27272727272727, 27.27272727272727, 27.27272727272727, 33.33333333333333, 33.33333333333333, 33.33333333333333, 33.33333333333333, 33.33333333333333]
          expect(item_flow_info.upstream_total_delivered).to eq [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
          expect(item_flow_info.upstream_delivered_per_period).to eq [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          expect(item_flow_info.downstream_total_delivered).to eq [0, 0, 0, 0, 0, 0, 0, 1, 1, 3, 3, 3, 3, 3, 3, 3]
          expect(item_flow_info.downstream_delivered_per_period).to eq [0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0]
          expect(item_flow_info.throughput_array_for_monte_carlo).to eq [0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0]

          expect(item_flow_info.demands_stages_count_hash[first_stage.name]).to be_nil
          expect(item_flow_info.demands_stages_count_hash[second_stage.name]).to eq [0, 0, 1, 1, 3, 3, 3, 3, 6, 6, 6, 6, 6, 6, 6]
          expect(item_flow_info.demands_stages_count_hash[third_stage.name]).to eq [0, 0, 1, 1, 2, 3, 3, 3, 6, 6, 6, 6, 6, 6, 6]
          expect(item_flow_info.demands_stages_count_hash[fourth_stage.name]).to eq [0, 0, 1, 1, 2, 3, 3, 3, 5, 5, 5, 5, 5, 5, 5]
          expect(item_flow_info.demands_stages_count_hash[fifth_stage.name]).to eq [0, 0, 1, 1, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4]
        end
      end
    end

    context 'with no data' do
      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns empty information' do
        item_flow_info = described_class.new(Demand.all, 10, dates_array.length, dates_array.last, 'week')

        item_flow_info.work_items_flow_behaviour(dates_array.first, dates_array.first, 0, true)

        expect(item_flow_info.demands).to eq []

        expect(item_flow_info.scope_per_period).to eq []
        expect(item_flow_info.ideal_per_period).to eq []
        expect(item_flow_info.throughput_per_period).to eq []
        expect(item_flow_info.accumulated_throughput).to eq []
        expect(item_flow_info.accumulated_bugs_opened_data_array).to eq []
        expect(item_flow_info.accumulated_bugs_closed_data_array).to eq []
        expect(item_flow_info.bugs_opened_data_array).to eq []
        expect(item_flow_info.bugs_closed_data_array).to eq []
        expect(item_flow_info.bugs_share_data_array).to eq []
        expect(item_flow_info.upstream_total_delivered).to eq []
        expect(item_flow_info.upstream_delivered_per_period).to eq []
        expect(item_flow_info.downstream_total_delivered).to eq []
        expect(item_flow_info.downstream_delivered_per_period).to eq []
        expect(item_flow_info.uncertain_scope).to eq 10
        expect(item_flow_info.current_scope).to eq 10
        expect(item_flow_info.period_size).to eq 0
      end
    end

    context 'with no end_sample_date' do
      it 'uses the current date as end sample date' do
        Fabricate :demand
        demands = Demand.all
        expect(demands).to receive(:opened_before_date).with(Time.zone.today).once.and_return(demands)
        described_class.new(demands, 10, 3.days.ago, nil, 'week')
      end
    end
  end
end
