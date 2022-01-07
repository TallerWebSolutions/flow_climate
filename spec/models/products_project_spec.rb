# frozen_string_literal: true

RSpec.describe ProductsProject, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :project }
  end
end
