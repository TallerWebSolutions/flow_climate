# frozen_string_literal: true

RSpec.describe DemandService, type: :service do
  before { travel_to Time.zone.local(2019, 9, 19, 10, 0, 0) }

  after { travel_back }

  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer }
  let(:project) { Fabricate :project, products: [product], start_date: 3.weeks.ago, end_date: 1.week.from_now }

  let(:stage) { Fabricate :stage, company: company, commitment_point: false, end_point: false, order: 1, projects: [project], stage_stream: :downstream }
  let(:other_stage) { Fabricate :stage, company: company, commitment_point: true, end_point: false, order: 0, projects: [project], stage_stream: :downstream }
  let(:end_stage) { Fabricate :stage, company: company, commitment_point: false, end_point: true, order: 2, projects: [project], stage_stream: :downstream }
  let(:out_stream_stage) { Fabricate :stage, company: company, commitment_point: false, end_point: false, order: 3, projects: [project], stage_stream: :out_stream }

  let!(:first_demand) { Fabricate :demand, project: project, demand_type: :bug, class_of_service: :expedite, created_date: 19.days.ago }
  let!(:second_demand) { Fabricate :demand, project: project, demand_type: :bug, class_of_service: :standard, created_date: 8.days.ago }
  let!(:third_demand) { Fabricate :demand, project: project, demand_type: :feature, class_of_service: :expedite, created_date: 2.days.ago }
  let!(:fourth_demand) { Fabricate :demand, project: project, demand_type: :chore, class_of_service: :expedite, created_date: 12.days.ago }

  let!(:first_transition) { Fabricate :demand_transition, stage: other_stage, demand: first_demand, last_time_in: 18.days.ago, last_time_out: 10.days.ago }
  let!(:second_transition) { Fabricate :demand_transition, stage: other_stage, demand: second_demand, last_time_in: 7.days.ago, last_time_out: 6.days.ago }
  let!(:third_transition) { Fabricate :demand_transition, stage: other_stage, demand: third_demand, last_time_in: 97.hours.ago, last_time_out: 96.hours.ago }
  let!(:fourth_transition) { Fabricate :demand_transition, stage: other_stage, demand: fourth_demand, last_time_in: 11.days.ago, last_time_out: 6.days.ago }

  let!(:fifth_transition) { Fabricate :demand_transition, stage: stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago }
  let!(:sixth_transition) { Fabricate :demand_transition, stage: stage, demand: second_demand, last_time_in: 6.days.ago, last_time_out: 4.days.ago }
  let!(:seventh_transition) { Fabricate :demand_transition, stage: stage, demand: third_demand, last_time_in: 96.hours.ago, last_time_out: 95.hours.ago }
  let!(:eigth_transition) { Fabricate :demand_transition, stage: stage, demand: fourth_demand, last_time_in: 6.days.ago, last_time_out: 1.day.ago }

  let!(:ninth_transition) { Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: 5.days.ago, last_time_out: 1.minute.ago }
  let!(:tenth_transition) { Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: 4.days.ago, last_time_out: 2.days.ago }
  let!(:eleventh_transition) { Fabricate :demand_transition, stage: end_stage, demand: third_demand, last_time_in: 95.hours.ago, last_time_out: 94.hours.ago }
  let!(:twelfth_transition) { Fabricate :demand_transition, stage: end_stage, demand: fourth_demand, last_time_in: 1.day.ago, last_time_out: 6.hours.ago }

  describe '#arrival_and_departure_data_per_week' do
    it 'returns the arrival and departure data by week' do
      arrival_departure_rate_data = described_class.instance.arrival_and_departure_data_per_week(Demand.all, 19.days.ago, Time.zone.now)
      expect(arrival_departure_rate_data.keys).to eq [Date.new(2019, 9, 22), Date.new(2019, 9, 15), Date.new(2019, 9, 8), Date.new(2019, 9, 1)]
      expect(arrival_departure_rate_data[Date.new(2019, 9, 22)]).to eq(arrived_in_week: [], std_dev_arrived: 0.0, std_dev_throughput: 0.0, throughput_in_week: [fourth_demand])
      expect(arrival_departure_rate_data[Date.new(2019, 9, 15)]).to eq(arrived_in_week: [second_demand, third_demand], std_dev_arrived: 1.4142135623730951, std_dev_throughput: 1.4142135623730951, throughput_in_week: [first_demand, second_demand, third_demand])
    end
  end

  describe '#lead_time_breakdown' do
    it 'returns the lead time breakdown to the entire demand array' do
      lead_time_breakdown = described_class.instance.lead_time_breakdown(Demand.all)

      expect(lead_time_breakdown.keys).to eq [other_stage.name, stage.name]
      expect(lead_time_breakdown[stage.name]).to match_array [eigth_transition, fifth_transition, seventh_transition, sixth_transition]
      expect(lead_time_breakdown[other_stage.name]).to match_array [first_transition, second_transition, third_transition, fourth_transition]

      empty_lead_time_breakdown = described_class.instance.lead_time_breakdown([])
      expect(empty_lead_time_breakdown).to eq({})
    end
  end
end
