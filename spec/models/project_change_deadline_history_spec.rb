# frozen_string_literal: true

RSpec.describe ProjectChangeDeadlineHistory, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :user }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :previous_date }
    it { is_expected.to validate_presence_of :new_date }
  end
end
