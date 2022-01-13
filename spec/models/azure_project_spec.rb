# frozen_string_literal: true

RSpec.describe AzureAzureProject, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:azure_product_config).class_name('Azure::AzureProductConfigsss') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project_name }
    it { is_expected.to validate_presence_of :project_id }
  end
end
