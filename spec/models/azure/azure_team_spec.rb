# frozen_string_literal: true

RSpec.describe Azure::AzureTeam, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:azure_product_config).class_name('Azure::AzureProductConfig') }
    it { is_expected.to have_one(:azure_project).class_name('Azure::AzureProject').dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team_name }
    it { is_expected.to validate_presence_of :team_id }
  end
end
