# frozen_string_literal: true

RSpec.describe RiskReviewService, type: :service do
  describe '#associate_demands_data' do
    let(:product) { Fabricate :product }

    let(:risk_review) { Fabricate :risk_review, product: product, meeting_date: Time.zone.today }

    let!(:first_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: 2.days.ago }
    let!(:second_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: 26.hours.ago }
    let!(:third_demand) { Fabricate :demand, product: product, risk_review: risk_review, end_date: 26.hours.ago }
    let!(:fourth_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: 4.days.ago }
    let!(:fifth_demand) { Fabricate :demand, product: product, risk_review: nil, end_date: Time.zone.tomorrow }

    let!(:first_block) { Fabricate :demand_block, demand: first_demand, risk_review: nil, unblock_time: 2.days.ago }
    let!(:second_block) { Fabricate :demand_block, demand: first_demand, risk_review: nil, unblock_time: 26.hours.ago }
    let!(:third_block) { Fabricate :demand_block, demand: second_demand, risk_review: risk_review, unblock_time: 26.hours.ago }
    let!(:fourth_block) { Fabricate :demand_block, demand: third_demand, risk_review: nil, unblock_time: 4.days.ago }
    let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, risk_review: nil, unblock_time: Time.zone.tomorrow }

    it 'associates the demands and demand blocks to the risk review' do
      described_class.instance.associate_demands_data(product, risk_review)
      expect(risk_review.reload.demands).to match_array [first_demand, third_demand, second_demand, fourth_demand]
      expect(risk_review.reload.demand_blocks).to match_array [first_block, third_block, second_block, fourth_block]
    end
  end
end
