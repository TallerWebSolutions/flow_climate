# frozen_string_literal: true

RSpec.describe ScoreMatrixAnswer, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :score_matrix_question }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :score_matrix_question }
      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_presence_of :answer_value }
    end

    context 'complex ones' do
      context 'uniqueness' do
        let(:product) { Fabricate :product }
        let(:score_matrix) { Fabricate :score_matrix, product: product }
        let(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }
        let(:other_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }

        let!(:score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 0 }

        let!(:dup_score_matrix_answer) { Fabricate.build :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 0 }
        let!(:diff_value_score_matrix_answer) { Fabricate.build :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 1 }
        let!(:diff_question_score_matrix_answer) { Fabricate.build :score_matrix_answer, score_matrix_question: other_score_matrix_question, answer_value: 0 }

        it { expect(score_matrix_answer.valid?).to be true }
        it { expect(diff_value_score_matrix_answer.valid?).to be true }
        it { expect(diff_question_score_matrix_answer.valid?).to be true }

        it 'reject duplicated ones' do
          expect(dup_score_matrix_answer.valid?).to be false
          expect(dup_score_matrix_answer.errors_on(:answer_value)).to eq [I18n.t('activerecord.errors.models.score_matrix_answer.value_already_used')]
        end
      end
    end
  end

  describe '#answer_score' do
    let(:score_matrix) { Fabricate :score_matrix }
    let(:other_score_matrix) { Fabricate :score_matrix }

    let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10 }
    let!(:other_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 30 }

    let!(:score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 5 }
    let!(:other_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: other_score_matrix_question, answer_value: 2 }

    it { expect(score_matrix_answer.answer_score).to eq 50 }
    it { expect(other_score_matrix_answer.answer_score).to eq 60 }
  end
end
