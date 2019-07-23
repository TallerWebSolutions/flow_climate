# frozen_string_literal: true

RSpec.describe PurgeIntegrationErrorsJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having integration errors' do
    let!(:first_integration_error) { Fabricate :integration_error, created_at: 4.days.ago }
    let!(:second_integration_error) { Fabricate :integration_error, created_at: 3.days.ago }
    let!(:third_integration_error) { Fabricate :integration_error, created_at: 2.days.ago }

    it 'collects a new cost to the week' do
      described_class.perform_now
      expect(IntegrationError.count).to eq 1
      expect(IntegrationError.last).to eq third_integration_error
    end
  end
end
