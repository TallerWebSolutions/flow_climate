# frozen_string_literal: true

class RiskReviewsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_product

  before_action :assign_risk_review, only: %i[show destroy edit update]

  def new
    @risk_review = RiskReview.new(product: @product)
    risk_reviews

    respond_to { |format| format.js { render 'risk_reviews/new' } }
  end

  def create
    @risk_review = RiskReview.create(risk_review_params.merge(company: @company, product: @product))

    if @risk_review.valid?
      flash[:notice] = I18n.t('risk_reviews.update.enqueued_associations')
      RiskReviewGeneratorJob.perform_later(@product, @risk_review, current_user.email, current_user.full_name, @risk_review.id, risk_review_url)
      risk_reviews
    end

    respond_to { |format| format.js { render 'risk_reviews/create' } }
  end

  def show
    @demand_blocks = @risk_review.demand_blocks.order(:block_time)
    @paged_demand_blocks = @risk_review.demand_blocks.order(:block_time).page(page_param)
  end

  def destroy
    @risk_review.destroy
    respond_to { |format| format.js { render 'risk_reviews/destroy' } }
  end

  def edit
    risk_reviews
    render 'risk_reviews/edit'
  end

  def update
    @risk_review.update(risk_review_params)
    if @risk_review.valid?
      RiskReviewGeneratorJob.perform_later(@product, @risk_review, current_user.email, current_user.full_name, @risk_review.id, risk_review_url)
      flash[:notice] = I18n.t('risk_reviews.update.enqueued_associations')
      risk_reviews
    end

    render 'risk_reviews/update'
  end

  private

  def risk_review_url
    company_product_risk_review_path(@company, @product, @risk_review)
  end

  def risk_reviews
    @risk_reviews ||= @product.risk_reviews.order(meeting_date: :desc)
  end

  def assign_risk_review
    @risk_review = @product.risk_reviews.find(params[:id])
  end

  def risk_review_params
    params.require(:risk_review).permit(:meeting_date, :lead_time_outlier_limit)
  end

  def assign_product
    @product = Product.find(params[:product_id])
  end

  def page_param
    @page_param ||= params[:page] || 1
  end
end
