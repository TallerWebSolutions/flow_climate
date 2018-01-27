# frozen_string_literal: true

class UsersController < AuthenticatedController
  def activate_email_notifications
    current_user.update(email_notifications: true)
    respond_to { |format| format.js { render file: 'users/reload_notifications.js.erb' } }
  end

  def deactivate_email_notifications
    current_user.update(email_notifications: false)
    respond_to { |format| format.js { render file: 'users/reload_notifications.js.erb' } }
  end
end
