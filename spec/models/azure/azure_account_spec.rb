# frozen_string_literal: true

RSpec.describe Azure::AzureAccount, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:azure_product_configs).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :azure_organization }
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_presence_of :password }
  end
end
