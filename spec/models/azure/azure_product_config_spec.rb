# frozen_string_literal: true

RSpec.describe Azure::AzureProductConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :azure_account }
    it { is_expected.to have_many(:azure_teams).class_name('Azure::AzureTeam').dependent(:destroy) }
    it { is_expected.to have_many(:azure_projects).class_name('Azure::AzureProject').dependent(:destroy) }
  end
end
