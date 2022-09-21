# frozen_string_literal: true

class UserCompanyRolesController < AuthenticatedController
  before_action :assign_user
  before_action :assign_user_company_role, only: %i[edit update]

  def edit; end

  def update
    @user_company_role.update(user_company_role_params)
    redirect_to edit_company_path(@company)
  end

  private

  def assign_user_company_role
    @user_company_role = UserCompanyRole.find(params[:id])
  end

  def assign_user
    @user = User.find(params[:user_id])
  end

  def user_company_role_params
    params.require(:user_company_role).permit(:start_date, :end_date, :user_role, :slack_user)
  end
end
