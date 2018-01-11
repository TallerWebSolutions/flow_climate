# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :assign_company

  def change_current_company
    current_user.update(last_company_id: @company.id)
    redirect_to company_path(@company)
  end

  private

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end
end
