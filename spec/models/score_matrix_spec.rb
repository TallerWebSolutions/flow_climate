# frozen_string_literal: true

RSpec.describe ScoreMatrix, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many :score_matrix_questions }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :product }
  end
end
