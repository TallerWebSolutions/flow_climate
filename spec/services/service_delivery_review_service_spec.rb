# frozen_string_literal: true

RSpec.describe ServiceDeliveryReviewService, type: :service do
  describe '#associate_demands_data' do
    let(:product) { Fabricate :product }
    let!(:project) { Fabricate :project, products: [product] }

    let(:service_delivery_review) { Fabricate :service_delivery_review, product: product, meeting_date: Time.zone.today }

    let!(:first_demand) { Fabricate :demand, product: product, project: project, service_delivery_review: nil, end_date: 2.days.ago }
    let!(:second_demand) { Fabricate :demand, product: product, project: project, service_delivery_review: nil, end_date: 26.hours.ago }
    let!(:third_demand) { Fabricate :demand, product: product, project: project, service_delivery_review: service_delivery_review, end_date: 26.hours.ago }
    let!(:fourth_demand) { Fabricate :demand, product: product, project: project, service_delivery_review: nil, end_date: 4.days.ago }
    let!(:fifth_demand) { Fabricate :demand, product: product, project: project, service_delivery_review: nil, end_date: Time.zone.tomorrow }
    let!(:sixth_demand) { Fabricate :demand, product: product, project: project, service_delivery_review: nil, end_date: 4.days.ago, discarded_at: Time.zone.yesterday }

    it 'associates the demands and demand blocks to the risk review' do
      described_class.instance.associate_demands_data(product, service_delivery_review)
      expect(service_delivery_review.reload.demands).to match_array [first_demand, third_demand, second_demand, fourth_demand, sixth_demand]
    end
  end
end
