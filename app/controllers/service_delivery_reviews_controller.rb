# frozen_string_literal: true

class ServiceDeliveryReviewsController < ApplicationController
  def show
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end
end
