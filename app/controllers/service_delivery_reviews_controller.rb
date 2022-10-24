# frozen_string_literal: true

class ServiceDeliveryReviewsController < AuthenticatedController
  before_action :assign_product

  before_action :assign_service_delivery_review, only: %i[show destroy edit update refresh]

  def show
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@service_delivery_review.demands, @service_delivery_review.start_date, @service_delivery_review.meeting_date, 'week')
  end

  def new
    @service_delivery_review = ServiceDeliveryReview.new(product: @product)
    service_delivery_reviews

    respond_to { |format| format.js { render 'service_delivery_reviews/new' } }
  end

  def edit
    service_delivery_reviews
    respond_to { |format| format.js { render 'service_delivery_reviews/edit' } }
  end

  def create
    @service_delivery_review = ServiceDeliveryReview.create(service_delivery_review_params.merge(company: @company, product: @product).merge(time_computed_params).merge(percent_computed_params))
    service_delivery_reviews
    process_valid_service_delivery_review if @service_delivery_review.valid?

    respond_to { |format| format.js { render 'service_delivery_reviews/create' } }
  end

  def update
    @service_delivery_review.update(service_delivery_review_params.merge(time_computed_params).merge(percent_computed_params))

    process_valid_service_delivery_review if @service_delivery_review.valid?

    respond_to { |format| format.js { render 'service_delivery_reviews/update' } }
  end

  def destroy
    @service_delivery_review.destroy
    service_delivery_reviews
    respond_to { |format| format.js { render 'service_delivery_reviews/destroy' } }
  end

  def refresh
    process_valid_service_delivery_review
    respond_to { |format| format.js { render 'service_delivery_reviews/update' } }
  end

  private

  def process_valid_service_delivery_review
    flash[:notice] = I18n.t('service_delivery_reviews.update.enqueued_associations')
    ServiceDeliveryReviewGeneratorJob.perform_later(@product, @service_delivery_review, current_user.email, current_user.full_name, @service_delivery_review.id, service_delivery_review_url)
    service_delivery_reviews
  end

  def service_delivery_reviews
    @service_delivery_reviews ||= @product.service_delivery_reviews.order(meeting_date: :desc)
  end

  def assign_service_delivery_review
    @service_delivery_review = @product.service_delivery_reviews.find(params[:id])
  end

  def service_delivery_review_params
    params.require(:service_delivery_review).permit(:meeting_date, :delayed_expedite_bottom_threshold, :delayed_expedite_top_threshold, :expedite_max_pull_time_sla, :lead_time_bottom_threshold, :lead_time_top_threshold, :quality_bottom_threshold, :quality_top_threshold)
  end

  def time_computed_params
    {
      expedite_max_pull_time_sla: service_delivery_review_params[:expedite_max_pull_time_sla].to_f * 1.hour,
      lead_time_bottom_threshold: service_delivery_review_params[:lead_time_bottom_threshold].to_f * 1.hour,
      lead_time_top_threshold: service_delivery_review_params[:lead_time_top_threshold].to_f * 1.hour
    }
  end

  def percent_computed_params
    {
      delayed_expedite_bottom_threshold: service_delivery_review_params[:delayed_expedite_bottom_threshold].to_f / 100.0,
      delayed_expedite_top_threshold: service_delivery_review_params[:delayed_expedite_top_threshold].to_f / 100.0,
      quality_bottom_threshold: service_delivery_review_params[:quality_bottom_threshold].to_f / 100.0,
      quality_top_threshold: service_delivery_review_params[:quality_top_threshold].to_f / 100.0
    }
  end

  def assign_product
    @product = Product.find(params[:product_id])
  end

  def service_delivery_review_url
    company_product_service_delivery_review_path(@company, @product, @service_delivery_review)
  end
end
