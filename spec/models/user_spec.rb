# frozen_string_literal: true

RSpec.describe User, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many(:companies) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :email }
  end
end
