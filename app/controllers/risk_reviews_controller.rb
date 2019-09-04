# frozen_string_literal: true

class RiskReviewsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_product

  before_action :assign_risk_review, only: :show

  def new
    @risk_review = RiskReview.new(product: @product)
    @risk_reviews = @product.risk_reviews.order(meeting_date: :desc)

    respond_to { |format| format.js { render 'risk_reviews/new.js.erb' } }
  end

  def create
    @risk_review = RiskReview.create(risk_review_params.merge(company: @company, product: @product))

    RiskReviewService.instance.associate_demands_data(@product, @risk_review) if @risk_review.valid?

    @risk_reviews = @product.risk_reviews.order(meeting_date: :desc)

    respond_to { |format| format.js { render 'risk_reviews/create.js.erb' } }
  end

  def show; end

  private

  def assign_risk_review
    @risk_review = @product.risk_reviews.find(params[:id])
  end

  def risk_review_params
    params.require(:risk_review).permit(:meeting_date, :lead_time_outlier_limit)
  end

  def assign_product
    @product = Product.find(params[:product_id])
  end
end
