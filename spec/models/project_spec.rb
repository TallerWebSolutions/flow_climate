# frozen_string_literal: true

RSpec.describe Project, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with(waiting: 0, executing: 1, finished: 2, cancelled: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :end_date }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :initial_scope }
  end
end
