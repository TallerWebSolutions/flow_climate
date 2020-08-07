# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :redirect_subdomain

  protect_from_forgery with: :exception

  private

  def not_found
    respond_to do |format|
      format.html { render 'layouts/404', status: :not_found, layout: false }
      format.js { render plain: '404 Not Found', status: :not_found }
      format.csv { render plain: '404 Not Found', status: :not_found }
    end
  end

  def redirect_subdomain
    redirect_to("https://flowclimate.com #{request.fullpath}", status: 301) if request.host == 'www.flowclimate.com'
  end

  def page_param
    @page_param ||= params[:page] || 1
  end
end
