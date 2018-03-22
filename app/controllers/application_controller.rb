# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  protect_from_forgery with: :exception

  private

  def not_found
    respond_to do |format|
      format.html { render file: Rails.root.join('public', '404'), layout: false, status: 404 }
      format.js { render plain: '404 Not Found', status: :not_found }
    end
  end
end
