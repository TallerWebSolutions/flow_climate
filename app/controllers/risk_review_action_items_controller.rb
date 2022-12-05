# frozen_string_literal: true

class RiskReviewActionItemsController < AuthenticatedController
  before_action :assign_product
  before_action :assign_risk_review

  def new
    @risk_review_action_item = RiskReviewActionItem.new(risk_review: @risk_review)
    memberships

    respond_to { |format| format.js { render 'risk_review_action_items/new' } }
  end

  def create
    @risk_review_action_item = RiskReviewActionItem.create(risk_review_action_item_params.merge(risk_review: @risk_review))

    flash[:notice] = I18n.t('risk_review_action_items.create.success') if @risk_review_action_item.valid?

    memberships
    risk_review_action_items

    respond_to { |format| format.js { render 'risk_review_action_items/create' } }
  end

  def destroy
    @risk_review_action_item = @risk_review.risk_review_action_items.find(params[:id])
    @risk_review_action_item.destroy

    risk_review_action_items
    respond_to { |format| format.js { render 'risk_review_action_items/destroy' } }
  end

  private

  def risk_review_action_items
    @risk_review_action_items = @risk_review.risk_review_action_items.order(:deadline)
  end

  def memberships
    @memberships ||= @product.memberships.active.sort_by(&:team_member_name)
  end

  def assign_risk_review
    @risk_review = @product.risk_reviews.find(params[:risk_review_id])
  end

  def risk_review_action_item_params
    params.require(:risk_review_action_item).permit(:created_date, :membership_id, :action_type, :description, :deadline)
  end

  def assign_product
    @product = Product.friendly.find(params[:product_id])
  end
end
