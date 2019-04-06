# frozen_string_literal: true

RSpec.describe IntegrationError, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:integration_type).with_values(jira: 0) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :integration_type }
    it { is_expected.to validate_presence_of :integration_error_text }
  end
end
