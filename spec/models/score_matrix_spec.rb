# frozen_string_literal: true

RSpec.describe ScoreMatrix do
  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many :score_matrix_questions }
  end

  describe '#total_weight' do
    let(:score_matrix) { Fabricate :score_matrix }
    let(:other_score_matrix) { Fabricate :score_matrix }

    let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10 }
    let!(:other_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 30 }

    it { expect(score_matrix.total_weight).to eq 40 }
    it { expect(other_score_matrix.total_weight).to eq 0 }
  end

  pending '#single_dimension?'
  pending '#questions_dimensions'
end
