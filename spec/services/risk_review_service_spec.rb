# frozen_string_literal: true

RSpec.describe RiskReviewService, type: :service do
  describe '#associate_demands_data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let!(:project) { Fabricate :project, company: company, products: [product] }
    let!(:stage) { Fabricate :stage, company: company, projects: [project], end_point: true }

    it 'creates the risk review data' do
      travel_to Time.zone.local(2020, 10, 19, 10, 0, 0) do
        risk_review = Fabricate :risk_review, product: product, meeting_date: Time.zone.today
        other_risk_review = Fabricate :risk_review, product: product, meeting_date: Time.zone.tomorrow

        first_demand = Fabricate :demand, product: product, project: project, risk_review: nil, discarded_at: nil
        second_demand = Fabricate :demand, product: product, project: project, risk_review: nil, discarded_at: nil
        third_demand = Fabricate :demand, product: product, project: project, risk_review: risk_review, discarded_at: nil
        fourth_demand = Fabricate :demand, product: product, project: project, risk_review: nil, discarded_at: nil
        fifth_demand = Fabricate :demand, product: product, project: project, risk_review: nil, created_date: Time.zone.tomorrow, discarded_at: nil
        sixth_demand = Fabricate :demand, product: product, project: project, risk_review: nil, created_date: 3.days.ago, discarded_at: Time.zone.yesterday
        seventh_demand = Fabricate :demand, product: product, project: project, risk_review: other_risk_review, discarded_at: nil

        Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 2.days.ago
        Fabricate :demand_transition, demand: second_demand, stage: stage, last_time_in: 26.hours.ago
        Fabricate :demand_transition, demand: third_demand, stage: stage, last_time_in: 26.hours.ago
        Fabricate :demand_transition, demand: fourth_demand, stage: stage, last_time_in: 4.days.ago
        Fabricate :demand_transition, demand: fifth_demand, stage: stage, last_time_in: Time.zone.tomorrow
        Fabricate :demand_transition, demand: sixth_demand, stage: stage, last_time_in: 4.days.ago
        Fabricate :demand_transition, demand: seventh_demand, stage: stage, last_time_in: 4.days.ago

        first_block = Fabricate :demand_block, demand: first_demand, risk_review: nil, block_time: 4.days.ago, unblock_time: 2.days.ago
        second_block = Fabricate :demand_block, demand: first_demand, risk_review: nil, block_time: 30.hours.ago, unblock_time: 26.hours.ago
        third_block = Fabricate :demand_block, demand: second_demand, risk_review: risk_review, block_time: 34.hours.ago, unblock_time: 26.hours.ago
        fourth_block = Fabricate :demand_block, demand: third_demand, risk_review: nil, block_time: 6.days.ago, unblock_time: 4.days.ago
        Fabricate :demand_block, demand: third_demand, risk_review: nil, block_time: 2.days.ago, unblock_time: Time.zone.tomorrow
        Fabricate :demand_block, demand: sixth_demand, risk_review: nil, discarded_at: Time.zone.yesterday

        first_impact = Fabricate :flow_impact, project: project, demand: first_demand, risk_review: nil, impact_date: 2.days.ago
        second_impact = Fabricate :flow_impact, project: project, demand: first_demand, risk_review: nil, impact_date: 26.hours.ago
        third_impact = Fabricate :flow_impact, project: project, demand: second_demand, risk_review: risk_review, impact_date: 26.hours.ago
        fourth_impact = Fabricate :flow_impact, project: project, demand: third_demand, risk_review: nil, impact_date: 4.days.ago
        fifth_impact = Fabricate :flow_impact, project: project, demand: third_demand, risk_review: nil, impact_date: Time.zone.tomorrow
        Fabricate :flow_impact, project: project, demand: sixth_demand, risk_review: nil, impact_date: 4.days.ago, discarded_at: Time.zone.yesterday

        described_class.instance.associate_demands_data(product, risk_review)
        expect(risk_review.reload.demands).to match_array [first_demand, third_demand, second_demand, fourth_demand]
        expect(risk_review.reload.demand_blocks).to match_array [first_block, third_block, second_block, fourth_block]
        expect(risk_review.reload.flow_impacts).to match_array [first_impact, third_impact, second_impact, fourth_impact, fifth_impact]
        expect(risk_review.reload.weekly_avg_blocked_time).to eq [153_000, 153_000]
      end
    end
  end
end
