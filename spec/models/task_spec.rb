# frozen_string_literal: true

RSpec.describe Task, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :created_date }
  end
end
