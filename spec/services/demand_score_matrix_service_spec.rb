# frozen_string_literal: true

RSpec.describe DemandScoreMatrixService, type: :service do
  describe '#compute_score' do
    context 'when the product has a score matrix' do
      let(:user) { Fabricate :user }
      let(:product) { Fabricate :product }
      let(:demand) { Fabricate :demand, product: product }

      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
      let!(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10 }
      let!(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25 }

      let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }
      let!(:second_answer) { Fabricate :score_matrix_answer, score_matrix_question: second_question, answer_value: 0 }
      let!(:third_answer) { Fabricate :score_matrix_answer, score_matrix_question: third_question, answer_value: 3 }

      let!(:first_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: first_answer }
      let!(:second_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: second_answer }

      it { expect(described_class.instance.compute_score(demand)).to eq 1.8181818181818181 }
    end

    context 'when the product has no score matrix' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }

      it { expect(described_class.instance.compute_score(demand)).to eq 0 }
    end

    context 'when the product has score matrix but no questions' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      it { expect(described_class.instance.compute_score(demand)).to eq 0 }
    end

    context 'when the product has score matrix and questions but no answers' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }

      it { expect(described_class.instance.compute_score(demand)).to eq 0 }
    end

    context 'when the product has score matrix and questions and answers but no one was answered' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
      let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }

      it { expect(described_class.instance.compute_score(demand)).to eq 0 }
    end
  end

  describe '#percentage_answered' do
    context 'when the product has a score matrix' do
      let(:user) { Fabricate :user }
      let(:product) { Fabricate :product }
      let(:demand) { Fabricate :demand, product: product }

      let(:score_matrix) { Fabricate :score_matrix, product: product }
      let(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
      let(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10 }
      let(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25 }

      let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }
      let!(:second_answer) { Fabricate :score_matrix_answer, score_matrix_question: second_question, answer_value: 0 }
      let!(:third_answer) { Fabricate :score_matrix_answer, score_matrix_question: third_question, answer_value: 3 }

      let!(:first_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: first_answer }
      let!(:second_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: second_answer }

      it { expect(described_class.instance.percentage_answered(demand)).to eq 66.66666666666666 }
    end

    context 'when the product has no score matrix' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }

      it { expect(described_class.instance.percentage_answered(demand)).to eq 0 }
    end

    context 'when the product has score matrix but no questions' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      it { expect(described_class.instance.percentage_answered(demand)).to eq 0 }
    end

    context 'when the product has score matrix and questions but no answers' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }

      it { expect(described_class.instance.percentage_answered(demand)).to eq 0 }
    end

    context 'when the product has score matrix and questions and answers but no one was answered' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
      let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }

      it { expect(described_class.instance.percentage_answered(demand)).to eq 0 }
    end
  end

  describe '#current_position_in_backlog' do
    context 'when the product has a score matrix' do
      let(:user) { Fabricate :user }
      let(:product) { Fabricate :product }
      let!(:first_demand) { Fabricate :demand, product: product }
      let!(:second_demand) { Fabricate :demand, product: product }
      let!(:third_demand) { Fabricate :demand, product: product }

      let(:score_matrix) { Fabricate :score_matrix, product: product }
      let(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
      let(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10 }
      let(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25 }

      let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }
      let!(:second_answer) { Fabricate :score_matrix_answer, score_matrix_question: second_question, answer_value: 0 }
      let!(:third_answer) { Fabricate :score_matrix_answer, score_matrix_question: third_question, answer_value: 3 }

      let!(:first_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: first_demand, score_matrix_answer: first_answer }
      let!(:second_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: first_demand, score_matrix_answer: second_answer }

      let!(:third_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: second_demand, score_matrix_answer: second_answer }

      it { expect(described_class.instance.current_position_in_backlog(first_demand)).to eq 1 }
      it { expect(described_class.instance.current_position_in_backlog(second_demand)).to eq 2 }
    end

    context 'when the product has no score matrix' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }

      it { expect(described_class.instance.current_position_in_backlog(demand)).to eq 1 }
    end

    context 'when the product has score matrix but no questions' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      it { expect(described_class.instance.current_position_in_backlog(demand)).to eq 1 }
    end

    context 'when the product has score matrix and questions but no answers' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }

      it { expect(described_class.instance.current_position_in_backlog(demand)).to eq 1 }
    end

    context 'when the product has score matrix and questions and answers but no one was answered' do
      let!(:product) { Fabricate :product }
      let!(:demand) { Fabricate :demand, product: product }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }
      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
      let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }

      it { expect(described_class.instance.current_position_in_backlog(demand)).to eq 1 }
    end
  end
end
