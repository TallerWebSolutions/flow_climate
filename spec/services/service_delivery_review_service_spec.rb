# frozen_string_literal: true

RSpec.describe ServiceDeliveryReviewService, type: :service do
  before { travel_to Time.zone.local(2018, 3, 27, 10, 0, 0) }

  describe '#associate_demands_data' do
    let(:product) { Fabricate :product }
    let!(:project) { Fabricate :project, products: [product] }

    let(:service_delivery_review) { Fabricate :service_delivery_review, product: product, meeting_date: Time.zone.today }

    let!(:first_demand) { Fabricate :demand, product: product, project: project, work_item_type: feature_type, service_delivery_review: nil, end_date: 2.days.ago }
    let!(:second_demand) { Fabricate :demand, product: product, project: project, work_item_type: feature_type, service_delivery_review: nil, end_date: 26.hours.ago }
    let!(:third_demand) { Fabricate :demand, product: product, project: project, work_item_type: feature_type, service_delivery_review: service_delivery_review, end_date: 26.hours.ago }
    let!(:fourth_demand) { Fabricate :demand, product: product, project: project, work_item_type: bug_type, service_delivery_review: nil, created_date: 6.days.ago, end_date: 4.days.ago }
    let!(:fifth_demand) { Fabricate :demand, product: product, project: project, work_item_type: chore_type, service_delivery_review: nil, end_date: Time.zone.tomorrow }
    let!(:sixth_demand) { Fabricate :demand, product: product, project: project, work_item_type: feature_type, service_delivery_review: nil, end_date: 4.days.ago, discarded_at: Time.zone.yesterday }
    let!(:seventh_demand) { Fabricate :demand, product: product, project: project, work_item_type: bug_type, service_delivery_review: nil, created_date: 1.day.ago, end_date: 1.day.ago }
    let!(:eigth_demand) { Fabricate :demand, product: product, project: project, work_item_type: bug_type, service_delivery_review: nil, created_date: 1.day.ago, end_date: 1.day.ago }

    it 'associates the demands and demand blocks to the risk review' do
      described_class.instance.associate_demands_data(product, service_delivery_review)
      expect(service_delivery_review.reload.demands).to match_array [first_demand, third_demand, second_demand, fourth_demand, sixth_demand, seventh_demand, eigth_demand]
      expect(service_delivery_review.reload.bugs_ids).to match_array [seventh_demand.id, eigth_demand.id]
    end
  end
end
