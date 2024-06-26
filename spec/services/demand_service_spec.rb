# frozen_string_literal: true

RSpec.describe DemandService, type: :service do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, company: company, customer: customer }

  let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
  let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
  let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

  describe '#lead_time_breakdown' do
    it 'returns the lead time breakdown to the entire demand array' do
      travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) do
        project = Fabricate :project, products: [product], start_date: 3.weeks.ago, end_date: 1.week.from_now
        stage = Fabricate :stage, company: company, commitment_point: false, end_point: false, order: 1, projects: [project], stage_stream: :downstream
        other_stage = Fabricate :stage, company: company, commitment_point: true, end_point: false, order: 0, projects: [project], stage_stream: :downstream
        end_stage = Fabricate :stage, company: company, commitment_point: false, end_point: true, order: 2, projects: [project], stage_stream: :downstream
        Fabricate :stage, company: company, commitment_point: false, end_point: false, order: 3, projects: [project], stage_stream: :out_stream

        first_demand = Fabricate :demand, project: project, work_item_type: bug_type, class_of_service: :expedite, created_date: 19.days.ago, demand_tags: %w[aaa ccc sbbrubles]
        second_demand = Fabricate :demand, project: project, work_item_type: bug_type, class_of_service: :standard, created_date: 8.days.ago, demand_tags: %w[sbbrubles xpto]
        third_demand = Fabricate :demand, project: project, work_item_type: feature_type, class_of_service: :expedite, created_date: 2.days.ago, demand_tags: %w[aaa ccc]
        fourth_demand = Fabricate :demand, project: project, work_item_type: chore_type, class_of_service: :expedite, created_date: 12.days.ago, demand_tags: %w[xpto]

        first_transition = Fabricate :demand_transition, stage: other_stage, demand: first_demand, last_time_in: 18.days.ago, last_time_out: 10.days.ago
        second_transition = Fabricate :demand_transition, stage: other_stage, demand: second_demand, last_time_in: 7.days.ago, last_time_out: 6.days.ago
        third_transition = Fabricate :demand_transition, stage: other_stage, demand: third_demand, last_time_in: 97.hours.ago, last_time_out: 96.hours.ago
        fourth_transition = Fabricate :demand_transition, stage: other_stage, demand: fourth_demand, last_time_in: 11.days.ago, last_time_out: 6.days.ago

        fifth_transition = Fabricate :demand_transition, stage: stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago
        sixth_transition = Fabricate :demand_transition, stage: stage, demand: second_demand, last_time_in: 6.days.ago, last_time_out: 4.days.ago
        seventh_transition = Fabricate :demand_transition, stage: stage, demand: third_demand, last_time_in: 96.hours.ago, last_time_out: 95.hours.ago
        eigth_transition = Fabricate :demand_transition, stage: stage, demand: fourth_demand, last_time_in: 6.days.ago, last_time_out: 1.day.ago

        Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: 5.days.ago, last_time_out: 1.minute.ago
        Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: 4.days.ago, last_time_out: 2.days.ago
        Fabricate :demand_transition, stage: end_stage, demand: third_demand, last_time_in: 95.hours.ago, last_time_out: 94.hours.ago
        Fabricate :demand_transition, stage: end_stage, demand: fourth_demand, last_time_in: 1.day.ago, last_time_out: 6.hours.ago

        lead_time_breakdown = described_class.instance.lead_time_breakdown(Demand.all)

        expect(lead_time_breakdown.keys).to eq [other_stage.name, stage.name]
        expect(lead_time_breakdown[stage.name]).to match_array [eigth_transition, fifth_transition, seventh_transition, sixth_transition]
        expect(lead_time_breakdown[other_stage.name]).to match_array [first_transition, second_transition, third_transition, fourth_transition]

        empty_lead_time_breakdown = described_class.instance.lead_time_breakdown([])
        expect(empty_lead_time_breakdown).to eq({})
      end
    end
  end

  describe '#search_engine' do
    it 'calls the specific methods in the query' do
      expect(DemandsRepository.instance).to(receive(:filter_demands_by_text).with(anything, 'foo').once { Demand.none })
      expect(DemandsRepository.instance).to(receive(:demand_state_query).with(anything, 'bla').once { Demand.none })
      expect(DemandsRepository.instance).to(receive(:demand_type_query).with(anything, 'bug').once { Demand.none })
      expect(DemandsRepository.instance).to(receive(:class_of_service_query).with(anything, 'expedite').once { Demand.none })
      expect(DemandsRepository.instance).to(receive(:demand_tags_query).with(anything, 'xpto sbbrubles').once { Demand.none })
      expect(DemandsRepository.instance).to(receive(:team_query).with(anything, 1).once { Demand.none })

      described_class.instance.search_engine(Demand.all, Time.zone.now, Time.zone.now, 'foo', 'bla', 'bug', 'expedite', 'xpto sbbrubles', 1)
    end
  end

  describe '#hours_per_demand' do
    context 'with data' do
      it 'returns the hour per demand' do
        travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) do
          Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, created_date: 19.days.ago, end_date: 2.days.ago, effort_upstream: 10, effort_downstream: 30
          Fabricate :demand, work_item_type: bug_type, class_of_service: :standard, created_date: 8.days.ago, end_date: 1.day.ago, effort_upstream: 15, effort_downstream: 5
          Fabricate :demand, work_item_type: feature_type, class_of_service: :expedite, created_date: 2.days.ago, end_date: 1.day.ago, effort_upstream: 40, effort_downstream: 35
          Fabricate :demand, work_item_type: chore_type, class_of_service: :expedite, created_date: 12.days.ago, end_date: 3.days.ago, effort_upstream: 100, effort_downstream: 110

          expect(described_class.instance.hours_per_demand(Demand.all)).to eq 86.25
        end
      end
    end

    context 'with no data' do
      it { expect(described_class.instance.hours_per_demand(Demand.none)).to eq 0 }
    end
  end

  describe '#flow_efficiency' do
    context 'with data' do
      it 'returns the flow efficiency' do
        travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) do
          Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, created_date: 19.days.ago, end_date: 2.days.ago, total_queue_time: 10, total_touch_time: 30
          Fabricate :demand, work_item_type: bug_type, class_of_service: :standard, created_date: 8.days.ago, end_date: 1.day.ago, total_queue_time: 15, total_touch_time: 5
          Fabricate :demand, work_item_type: feature_type, class_of_service: :expedite, created_date: 2.days.ago, end_date: 1.day.ago, total_queue_time: 40, total_touch_time: 35
          Fabricate :demand, work_item_type: chore_type, class_of_service: :expedite, created_date: 12.days.ago, end_date: 3.days.ago, total_queue_time: 100, total_touch_time: 110

          expect(described_class.instance.flow_efficiency(Demand.all)).to eq 52.17391304347827
        end
      end
    end

    context 'with no data' do
      it { expect(described_class.instance.flow_efficiency(Demand.all)).to eq 0 }
    end
  end

  describe '#average_speed' do
    context 'with data' do
      it 'returns the correct average speed based on the demands list' do
        travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) do
          Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, created_date: 19.days.ago, end_date: 2.days.ago
          Fabricate :demand, work_item_type: bug_type, class_of_service: :standard, created_date: 8.days.ago, end_date: 1.day.ago
          Fabricate :demand, work_item_type: feature_type, class_of_service: :expedite, created_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :demand, work_item_type: chore_type, class_of_service: :expedite, created_date: 12.days.ago, end_date: 3.days.ago
          Fabricate :demand, work_item_type: chore_type, class_of_service: :expedite, created_date: 12.days.ago, end_date: nil

          expect(described_class.instance.average_speed(Demand.all)).to eq 1.0
        end
      end
    end

    context 'with no data' do
      it { expect(described_class.instance.average_speed(Demand.none)).to eq 0 }
    end
  end

  describe '#similar_p80_project' do
    context 'with data' do
      it 'returns the correct average speed based on the demands list' do
        travel_to Time.zone.local(2020, 12, 8, 13, 32, 38) do
          project = Fabricate :project
          demand = Fabricate :demand, project: project, work_item_type: bug_type, class_of_service: :expedite, commitment_date: 19.days.ago, end_date: 2.days.ago
          Fabricate :demand, project: project, work_item_type: bug_type, class_of_service: :intangible, commitment_date: 8.days.ago, end_date: 1.day.ago
          Fabricate :demand, project: project, work_item_type: feature_type, class_of_service: :expedite, commitment_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :demand, project: project, work_item_type: chore_type, class_of_service: :standard, commitment_date: 12.days.ago, end_date: 3.days.ago
          Fabricate :demand, project: project, work_item_type: chore_type, class_of_service: :expedite, commitment_date: 12.days.ago, end_date: nil
          Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, commitment_date: 12.days.ago, end_date: 3.days.ago

          expect(described_class.instance.similar_p80_project(demand)).to be_within(0.1).of(1_468_800.0)
        end
      end
    end

    context 'with no data' do
      it 'returns the correct average speed based on the demands list' do
        travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) do
          demand = Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, commitment_date: 19.days.ago, end_date: nil
          expect(described_class.instance.similar_p80_project(demand)).to eq 0
        end
      end
    end
  end

  describe '#similar_p80_team' do
    context 'with data' do
      it 'returns the correct average speed based on the demands list' do
        travel_to Time.zone.local(2020, 12, 8, 13, 32, 38) do
          team = Fabricate :team
          demand = Fabricate :demand, team: team, work_item_type: bug_type, class_of_service: :expedite, commitment_date: 19.days.ago, end_date: 2.days.ago
          Fabricate :demand, team: team, work_item_type: bug_type, class_of_service: :intangible, commitment_date: 8.days.ago, end_date: 1.day.ago
          Fabricate :demand, team: team, work_item_type: feature_type, class_of_service: :expedite, commitment_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :demand, team: team, work_item_type: chore_type, class_of_service: :standard, commitment_date: 12.days.ago, end_date: 3.days.ago
          Fabricate :demand, team: team, work_item_type: chore_type, class_of_service: :expedite, commitment_date: 12.days.ago, end_date: nil
          Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, commitment_date: 12.days.ago, end_date: 3.days.ago

          expect(described_class.instance.similar_p80_team(demand)).to be_within(0.1).of(1_468_800.0)
        end
      end
    end

    context 'with no data' do
      it 'returns the correct average speed based on the demands list' do
        travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) do
          demand = Fabricate :demand, work_item_type: bug_type, class_of_service: :expedite, commitment_date: 19.days.ago, end_date: nil
          expect(described_class.instance.similar_p80_team(demand)).to eq 0
        end
      end
    end
  end
end
