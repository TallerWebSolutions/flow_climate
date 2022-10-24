# frozen_string_literal: true

RSpec.describe CustomersProject do
  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :project }
  end
end
