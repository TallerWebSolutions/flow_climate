# frozen_string_literal: true

class ProductUsersController < AuthenticatedController
  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  private

  def assign_company
    @company = Company.friendly.find(params[:company_id]&.downcase)
  end
end
