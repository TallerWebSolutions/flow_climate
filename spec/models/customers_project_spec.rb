# frozen_string_literal: true

RSpec.describe CustomersProject, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :project }
  end
end
