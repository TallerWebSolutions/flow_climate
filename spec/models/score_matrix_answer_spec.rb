# frozen_string_literal: true

RSpec.describe ScoreMatrixAnswer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :score_matrix_question }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :score_matrix_question }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :answer_value }
  end
end
