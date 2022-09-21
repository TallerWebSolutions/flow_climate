# frozen_string_literal: true

class ReplenishingConsolidationsController < AuthenticatedController
  prepend_view_path Rails.public_path

  def index
    render 'spa-build/index'
  end
end
