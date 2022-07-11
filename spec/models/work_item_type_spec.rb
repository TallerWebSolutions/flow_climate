# frozen_string_literal: true

RSpec.describe WorkItemType, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:item_level).with_values(demand: 0, task: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :item_level }
  end
end
