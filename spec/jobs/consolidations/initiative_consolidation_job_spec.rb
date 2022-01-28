# frozen_string_literal: true

RSpec.describe Consolidations::InitiativeConsolidationJob do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('consolidations')
    end
  end

  context 'with initiatives to collect data' do
    it 'saves de consolidation' do
      initiative = Fabricate :initiative

      described_class.perform_now(initiative)

      expect(Consolidations::InitiativeConsolidation.count).to eq 1
    end
  end
end
