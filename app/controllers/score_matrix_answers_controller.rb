# frozen_string_literal: true

class ScoreMatrixAnswersController < AuthenticatedController
  before_action :assign_product
  before_action :assign_score_matrix_question
  before_action :assign_score_matrix_answer, only: :destroy

  def create
    @score_matrix_answer = ScoreMatrixAnswer.new(score_matrix_answer_params.merge(score_matrix_question: @score_matrix_question))

    if @score_matrix_answer.save
      flash[:notice] = I18n.t('score_matrix_answers.create.success')
    else
      flash[:error] = @score_matrix_answer.errors.full_messages.join(', ')
    end

    redirect_to company_product_score_matrix_question_path(@company, @product, @score_matrix_question)
  end

  def destroy
    @score_matrix_answer.destroy
    @score_matrix_answers = @score_matrix_question.score_matrix_answers.order(:answer_value)
    render 'score_matrix_answers/destroy'
  end

  private

  def assign_score_matrix_answer
    @score_matrix_answer = @score_matrix_question.score_matrix_answers.find(params[:id])
  end

  def assign_score_matrix_question
    @score_matrix_question = @product.score_matrix.score_matrix_questions.find(params[:score_matrix_question_id])
  end

  def assign_product
    @product = @company.products.friendly.find(params[:product_id])
  end

  def score_matrix_answer_params
    params.require(:score_matrix_answer).permit(:answer_value, :description)
  end
end
