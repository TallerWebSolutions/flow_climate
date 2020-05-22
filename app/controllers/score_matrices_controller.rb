# frozen_string_literal: true

class ScoreMatricesController < AuthenticatedController
  before_action :assign_score_matrix

  def show
    @backlog_demands = @score_matrix.product.demands.not_started.order(demand_score: :desc)
  end

  private

  def assign_score_matrix
    @score_matrix = ScoreMatrix.find(params[:id])
  end
end
