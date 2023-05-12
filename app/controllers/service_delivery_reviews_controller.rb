# frozen_string_literal: true

class ServiceDeliveryReviewsController < AuthenticatedController
  def show
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end
end
