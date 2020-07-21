# frozen-string-literal: true

RSpec.describe ItemAssignmentNotification, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :item_assignment }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :item_assignment }
  end
end
