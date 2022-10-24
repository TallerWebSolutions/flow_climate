# frozen_string_literal: true

RSpec.describe Azure::AzureAccount do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:azure_product_configs).class_name('Azure::AzureProductConfig').dependent(:destroy) }
    it { is_expected.to have_many(:azure_custom_fields).class_name('Azure::AzureCustomField').dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :azure_organization }
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_presence_of :encrypted_password }
  end
end
