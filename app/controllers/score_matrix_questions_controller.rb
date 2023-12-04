# frozen_string_literal: true

class ScoreMatrixQuestionsController < AuthenticatedController
  before_action :assign_product
  before_action :assign_score_matrix_question, only: %i[show destroy edit update]

  def show
    @score_matrix_answers = @score_matrix_question.score_matrix_answers.order(:answer_value)
    @score_matrix_answer = ScoreMatrixAnswer.new(score_matrix_question: @score_matrix_question)
  end

  def new
    @score_matrix_question = ScoreMatrixQuestion.new(score_matrix: product_score_matrix)

    render :new
  end

  def edit; end

  def create
    @score_matrix_question = ScoreMatrixQuestion.new(score_matrix_question_params.merge(score_matrix: product_score_matrix))

    if @score_matrix_question.save
      update_score_for_product_demands

      flash[:notice] = I18n.t('score_matrix_questions.create.success')
      redirect_to company_product_path(@company, @product)
    else
      flash[:error] = @score_matrix_question.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    @score_matrix_question.update(score_matrix_question_params)

    if @score_matrix_question.valid?
      update_score_for_product_demands

      flash[:notice] = I18n.t('score_matrix_questions.update.success')
      redirect_to company_product_path(@company, @product)
    else
      flash[:error] = @score_matrix_question.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @score_matrix_question.destroy
    @score_matrix_questions = @product.score_matrix_questions.order(:question_type, :question_weight, :description)
    render 'score_matrix_questions/destroy'
  end

  private

  def update_score_for_product_demands
    @product.demands.kept.scored_demands.each do |demand|
      final_score = DemandScoreMatrixService.instance.compute_score(demand)

      demand.update(demand_score: final_score)
    end
  end

  def assign_score_matrix_question
    @score_matrix_question = @product.score_matrix.score_matrix_questions.find(params[:id])
  end

  def assign_product
    @product = @company.products.friendly.find(params[:product_id])
  end

  def score_matrix_question_params
    params.require(:score_matrix_question).permit(:question_weight, :question_type, :description, score_matrix_answers: %i[answer_value description])
  end

  def product_score_matrix
    @product_score_matrix ||= @product.score_matrix || ScoreMatrix.new(product: @product)
  end
end
