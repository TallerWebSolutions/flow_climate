# frozen_string_literal: true

RSpec.describe OperationWeeklyResult, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :result_date }
    it { is_expected.to validate_presence_of :billable_count }
    it { is_expected.to validate_presence_of :operation_week_value }
  end
end
