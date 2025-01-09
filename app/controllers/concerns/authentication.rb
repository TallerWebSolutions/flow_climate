# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :assign_company
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :assign_company, **options
    end
  end

  def check_admin
    return true if Current.user.admin?

    redirect_to root_path
  end

  def user_gold_check
    return true if Current.user.admin?

    user_plan = Current.user.current_user_plan
    return true unless user_plan.blank? || user_plan.lite? || user_plan.trial?

    no_plan_to_access(:gold)
  end

  private

  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path, alert: 'Sign in to continue' unless authenticated?
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end

  def assign_company
    @company = Company.friendly.find(params[:company_id]&.downcase)
    not_found unless Current.user.active_access_to_company?(@company)
  end
end
