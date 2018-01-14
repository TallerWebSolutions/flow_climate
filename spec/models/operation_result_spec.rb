# frozen_string_literal: true

RSpec.describe OperationResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :result_date }
    it { is_expected.to validate_presence_of :people_billable_count }
    it { is_expected.to validate_presence_of :operation_week_value }
    it { is_expected.to validate_presence_of :available_hours }
    it { is_expected.to validate_presence_of :delivered_hours }
    it { is_expected.to validate_presence_of :total_th }
    it { is_expected.to validate_presence_of :total_opened_bugs }
    it { is_expected.to validate_presence_of :total_accumulated_closed_bugs }
  end
end
