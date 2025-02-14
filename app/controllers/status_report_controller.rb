# frozen_string_literal: true

class StatusReportController < ActionController::Base
  def show
    @product_name = params[:product_name]
    render :show
  end
end
