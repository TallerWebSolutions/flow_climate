# frozen_string_literal: true

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :users }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
  end
end
