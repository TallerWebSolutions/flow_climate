# frozen_string_literal: true

RSpec.describe DemandScoreMatrix, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :demand }
    it { is_expected.to belong_to :score_matrix_answer }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :user }
      it { is_expected.to validate_presence_of :demand }
      it { is_expected.to validate_presence_of :score_matrix_answer }
    end

    context 'complex ones' do
      context 'already_answered_question' do
        let(:user) { Fabricate :user }
        let(:product) { Fabricate :product }
        let(:demand) { Fabricate :demand, product: product }

        let(:score_matrix) { Fabricate :score_matrix, product: product }
        let(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }

        let(:score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question }
        let(:other_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question }
        let(:diff_question_score_matrix_answer) { Fabricate :score_matrix_answer }

        let!(:demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: score_matrix_answer }
        let!(:duplicated_answer) { Fabricate.build :demand_score_matrix, demand: demand, score_matrix_answer: score_matrix_answer }
        let!(:new_answer) { Fabricate.build :demand_score_matrix, demand: demand, score_matrix_answer: diff_question_score_matrix_answer }

        it 'invalidates the duplicated data' do
          expect(duplicated_answer.valid?).to be false
          expect(duplicated_answer.errors[:demand]).to eq [I18n.t('activerecord.errors.models.demand_score_matrix.already_answered')]
        end

        it { expect(new_answer.valid?).to be true }
      end
    end
  end
end
