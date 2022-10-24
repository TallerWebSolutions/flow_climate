# frozen_string_literal: true

RSpec.describe RiskReviewActionItem do
  context 'enums' do
    it { is_expected.to define_enum_for(:action_type).with_values(technical_change: 0, permissions_update: 1, customer_alignment: 2, internal_process_change: 3, cadences_change: 4, internal_comunication_change: 5, training: 6, guidance: 7) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:risk_review) }
    it { is_expected.to belong_to(:membership) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :created_date }
    it { is_expected.to validate_presence_of :action_type }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :deadline }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:product).to(:risk_review) }
  end
end
