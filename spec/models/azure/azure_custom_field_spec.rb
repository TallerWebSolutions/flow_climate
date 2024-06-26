# frozen_string_literal: true

RSpec.describe Azure::AzureCustomField do
  context 'enuns' do
    it { is_expected.to define_enum_for(:custom_field_type).with_values(project_name: 0, team_name: 1, epic_name: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :azure_account }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :custom_field_name }
    it { is_expected.to validate_presence_of :custom_field_type }
  end
end
