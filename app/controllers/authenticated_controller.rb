# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!

  private

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end
end
