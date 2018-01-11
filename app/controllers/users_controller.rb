# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :assign_company

  def change_current_company
    current_user.update(last_company_id: @company.id)
    redirect_to company_path(@company)
  end
end
