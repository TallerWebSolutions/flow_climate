# frozen_string_literal: true

RSpec.describe DemandScoreMatrixService, type: :service do
  shared_context 'demand score matrix data' do
    let(:user) { Fabricate :user }
    let(:product) { Fabricate :product }
    let!(:first_demand) { Fabricate :demand, product: product, commitment_date: nil, end_date: nil }
    let!(:second_demand) { Fabricate :demand, product: product, commitment_date: nil, end_date: nil }
    let!(:third_demand) { Fabricate :demand, product: product, commitment_date: nil, end_date: nil }

    let(:score_matrix) { Fabricate :score_matrix, product: product }
    let(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20 }
    let(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10 }
    let(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25 }

    let!(:first_answer) { Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5 }
    let!(:second_answer) { Fabricate :score_matrix_answer, score_matrix_question: second_question, answer_value: 1 }
    let!(:third_answer) { Fabricate :score_matrix_answer, score_matrix_question: third_question, answer_value: 3 }

    let!(:first_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: first_demand, score_matrix_answer: first_answer }
    let!(:second_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: first_demand, score_matrix_answer: second_answer }

    let!(:third_demand_score_matrix) { Fabricate :demand_score_matrix, user: user, demand: second_demand, score_matrix_answer: second_answer }
  end

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
      include_context 'demand score matrix data'

      it { expect(described_class.instance.percentage_answered(first_demand)).to eq 66.66666666666666 }
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
      include_context 'demand score matrix data'

      before do
        final_score = described_class.instance.compute_score(first_demand)
        first_demand.update(demand_score: final_score)

        final_score = described_class.instance.compute_score(second_demand)
        second_demand.update(demand_score: final_score)

        final_score = described_class.instance.compute_score(third_demand)
        third_demand.update(demand_score: final_score)
      end

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

  describe '#demands_list' do
    include_context 'demand score matrix data'

    let(:committed_demand) { Fabricate :demand, product: product, commitment_date: Time.zone.now }
    let(:other_committed_demand) { Fabricate :demand, product: product, commitment_date: Time.zone.now }

    it { expect(described_class.instance.demands_list(committed_demand)).to match_array [committed_demand, other_committed_demand, first_demand, second_demand, third_demand] }
    it { expect(described_class.instance.demands_list(first_demand)).to match_array [first_demand, second_demand, third_demand] }
  end
end
