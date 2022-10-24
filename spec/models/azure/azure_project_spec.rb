# frozen_string_literal: true

RSpec.describe Azure::AzureProject do
  context 'associations' do
    it { is_expected.to belong_to(:azure_team).class_name('Azure::AzureTeam') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project_name }
    it { is_expected.to validate_presence_of :project_id }
  end
end
