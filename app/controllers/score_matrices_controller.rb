# frozen_string_literal: true

class ScoreMatricesController < AuthenticatedController
  before_action :assign_score_matrix

  def show
    assign_backlog_demands

    @demand_score_matrix = DemandScoreMatrix.new
    @score_matrix_questions = if questions_dimension.blank? || questions_dimension == 'customer_dimension'
                                @score_matrix.score_matrix_questions.customer_dimension.order(question_weight: :desc)
                              else
                                @score_matrix.score_matrix_questions.service_provider_dimension.order(question_weight: :desc)
                              end
  end

  def customer_dimension
    assign_backlog_demands
    @questions_dimension = 'customer_dimension'

    @score_matrix_questions = @score_matrix.score_matrix_questions.customer_dimension.order(question_weight: :desc)

    @demand_score_matrix = DemandScoreMatrix.new

    render :show
  end

  def service_provider_dimension
    assign_backlog_demands
    @questions_dimension = 'service_provider_dimension'

    @score_matrix_questions = @score_matrix.score_matrix_questions.service_provider_dimension.order(question_weight: :desc)

    @demand_score_matrix = DemandScoreMatrix.new

    render :show
  end

  private

  def questions_dimension
    @questions_dimension ||= params['questions_dimension']
  end

  def assign_backlog_demands
    @backlog_demands = @score_matrix.product.demands.not_started.order('demand_score desc, created_at asc')
  end

  def assign_score_matrix
    @score_matrix = ScoreMatrix.find(params[:id])
  end
end
