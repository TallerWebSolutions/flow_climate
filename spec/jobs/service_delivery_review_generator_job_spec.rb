# frozen_string_literal: true

RSpec.describe ServiceDeliveryReviewGeneratorJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('low')
    end
  end

  context 'with valid data' do
    let(:first_user) { Fabricate :user }
    let!(:company) { Fabricate :company, users: [first_user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

    let!(:service_delivery_review) { Fabricate :risk_review, product: product }

    it 'calls the service and send an email when it finishes' do
      expect(ServiceDeliveryReviewService.instance).to(receive(:associate_demands_data).with(product, service_delivery_review).once)
      expect(UserNotifierMailer).to(receive(:async_activity_finished).once)

      described_class.perform_now(product, service_delivery_review, first_user.email, first_user.full_name, service_delivery_review.id, 'http://foo.com')
    end
  end
end
