# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :check_admin, only: %i[toggle_admin admin_dashboard]
  before_action :assign_user, only: %i[toggle_admin update]

  def admin_dashboard
    @users_list = User.all.order(%i[last_name first_name])
    @companies_list = Company.all.order(:name)
  end

  def activate_email_notifications
    current_user.update(email_notifications: true)
    respond_to { |format| format.js { render 'users/reload_notifications.js.erb' } }
  end

  def deactivate_email_notifications
    current_user.update(email_notifications: false)
    respond_to { |format| format.js { render 'users/reload_notifications.js.erb' } }
  end

  def toggle_admin
    @user.toggle_admin
    redirect_to admin_dashboard_users_path
  end

  def show
    @user = User.find(params[:id])
    @companies_list = @user.companies.order(:name)
    assign_user_dependencies
  end

  def update
    return redirect_to user_path(@user) if @user.update(user_params)

    @companies_list = @user.companies.order(:name)
    assign_user_dependencies
    render :show
  end

  private

  def assign_user_dependencies
    @user_plans = @user.user_plans.order(finish_at: :desc)
    @demand_data_processment = @user.demand_data_processments.order(created_at: :desc)
  end

  def user_params
    params.require(:user).permit(:avatar, :first_name, :last_name)
  end

  def assign_user
    @user = User.find(params[:id])
  end
end
