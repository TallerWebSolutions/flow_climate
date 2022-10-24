# frozen_string_literal: true

RSpec.describe TeamResource do
  context 'enuns' do
    it { is_expected.to define_enum_for(:resource_type).with_values(cloud: 0, continuous_integration: 1, library_manager: 2, code_hosting_platform: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :team_resource_allocations }
  end
end
