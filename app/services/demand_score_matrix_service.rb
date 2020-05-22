# frozen_string_literal: true

class DemandScoreMatrixService
  include Singleton

  def compute_score(demand)
    return 0 if demand_unscored?(demand)

    score_matrix_total_weight = demand.product.score_matrix.total_weight

    demand_answers = demand.demand_score_matrices.map(&:score_matrix_answer)

    total_answers_score = demand_answers.map(&:answer_score).sum

    total_answers_score / score_matrix_total_weight.to_f
  end

  def percentage_answered(demand)
    return 0 if demand_unscored?(demand)

    total_questions = demand.product.score_matrix.score_matrix_questions.count

    demand_answers = demand.demand_score_matrices.map(&:score_matrix_answer)

    (demand_answers.count / total_questions.to_f) * 100
  end

  def current_position_in_backlog(demand)
    demands_list(demand).find_index(demand) + 1
  end

  def demands_list(demand)
    if demand.not_started?
      demand.product.demands.kept.not_started.order(demand_score: :desc)
    else
      demand.product.demands.kept.order(demand_score: :desc)
    end
  end

  private

  def demand_unscored?(demand)
    demand.product.score_matrix.blank? || demand.product.score_matrix.score_matrix_questions.blank?
  end
end
