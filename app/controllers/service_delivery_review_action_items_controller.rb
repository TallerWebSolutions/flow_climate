# frozen_string_literal: true

class ServiceDeliveryReviewActionItemsController < AuthenticatedController
  before_action :assign_product
  before_action :assign_service_delivery_review

  def new
    @service_delivery_review_action_item = ServiceDeliveryReviewActionItem.new(service_delivery_review: @service_delivery_review)
    memberships
  end

  def create
    @service_delivery_review_action_item = ServiceDeliveryReviewActionItem.create(service_delivery_review_action_item_params.merge(service_delivery_review: @service_delivery_review))

    flash[:notice] = I18n.t('service_delivery_review_action_items.create.success') if @service_delivery_review_action_item.valid?

    memberships
    service_delivery_review_action_items

    respond_to { |format| format.js { render 'service_delivery_review_action_items/create' } }
  end

  def destroy
    @service_delivery_review_action_item = @service_delivery_review.service_delivery_review_action_items.find(params[:id])
    @service_delivery_review_action_item.destroy

    service_delivery_review_action_items
    respond_to { |format| format.js { render 'service_delivery_review_action_items/destroy' } }
  end

  private

  def service_delivery_review_action_items
    @service_delivery_review_action_items = @service_delivery_review.service_delivery_review_action_items.order(:deadline)
  end

  def memberships
    @memberships ||= @product.memberships.active.sort_by(&:team_member_name)
  end

  def assign_service_delivery_review
    @service_delivery_review = @product.service_delivery_reviews.find(params[:service_delivery_review_id])
  end

  def service_delivery_review_action_item_params
    params.require(:service_delivery_review_action_item).permit(:created_date, :membership_id, :action_type, :description, :deadline)
  end

  def assign_product
    @product = Product.friendly.find(params[:product_id])
  end
end
