# frozen_string_literal: true

RSpec.describe Azure::AzureProductConfig do
  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :azure_account }
    it { is_expected.to have_one(:azure_team).class_name('Azure::AzureTeam').dependent(:destroy) }
  end
end
