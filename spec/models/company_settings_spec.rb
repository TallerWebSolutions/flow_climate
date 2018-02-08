# frozen_string_literal: true

RSpec.describe CompanySettings, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end
  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :max_active_parallel_projects }
    it { is_expected.to validate_presence_of :max_flow_pressure }
  end
end
