# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :check_admin, only: :toggle_admin
  before_action :assign_user, only: %i[toggle_admin update]

  def activate_email_notifications
    current_user.update(email_notifications: true)
    respond_to { |format| format.js { render file: 'users/reload_notifications.js.erb' } }
  end

  def deactivate_email_notifications
    current_user.update(email_notifications: false)
    respond_to { |format| format.js { render file: 'users/reload_notifications.js.erb' } }
  end

  def toggle_admin
    @user.toggle_admin
    redirect_to users_path
  end

  def show
    @user = User.find(params[:id])
    assign_user_dependencies
  end

  def update
    return redirect_to user_path(@user) if @user.update(user_params)

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
