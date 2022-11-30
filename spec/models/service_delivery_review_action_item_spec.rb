# frozen_string_literal: true

RSpec.describe ServiceDeliveryReviewActionItem do
  context 'enums' do
    it { is_expected.to define_enum_for(:action_type).with_values(cadences_change: 0, internal_comunication_change: 1, training: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:service_delivery_review) }
    it { is_expected.to belong_to(:membership) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :action_type }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :deadline }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:product).to(:service_delivery_review) }
  end
end
