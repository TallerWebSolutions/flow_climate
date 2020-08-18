# frozen-string-literal: true

RSpec.describe Consolidations::ReplenishingConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end
end
