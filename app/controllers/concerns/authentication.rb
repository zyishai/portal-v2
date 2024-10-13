module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
    helper_method :current_user
    helper_method :user_signed_in?
  end

  def login(user)
    reset_session
    active_session = user.active_sessions.create!(user_agent: request.user_agent, ip_address: request.ip)
    session[:current_active_session_id] = active_session.id

    active_session
  end

  def forget_active_session
    cookies.delete :remember_token
  end

  def remember(active_session)
    user.regenerate_remember_token
    cookies.permanent.encrypted[:remember_token] = active_session.remember_token
  end

  def logout
    active_session = ActiveSession.find_by(id: session[:current_active_session_id])
    reset_session
    active_session.destroy! if active_session.present?
  end

  def redirect_if_authenticated
    redirect_to root_path, alert: "You are already logged in." if user_signed_in?
  end

  def authenticate_user!
    store_location
    redirect_to login_path, alert: "You need to login to access that page." unless user_signed_in?
  end

  private

  def store_location
    session[:user_return_to] = request.original_url if request.get? && request.local?
  end

  def current_user
    # REVIEW - we fetch the user everytime we access this helper.
    # Why? if the current session got destroyed but we'd use the ||= operator,
    # the `Current.user` property would keep the user instead of returning to `nil`,
    # even through `current_active_session_id` is now destroyed due to the ||= operator.
    # By re-fetching the user everytime we make sure that when `current_active_session_id`
    # got destroyed, the `Current.user` would be `nil`.
    # A symptom of the issue was happening when I was signing out of my current session
    # from my `/account` route. Since `Current.user` was *not* `nil`, the `destroy` method
    # on `ActiveSessionsController` was trying to redirect to the `/account` route instead
    # of to the `/` route, and I got redirected to the login page with the alert that I need
    # to login to access this route. I was confused until I realized this bug.
    # So, to summary: This change is not ideal, but it solved the bug mentioned. It'd better
    # if I could destroy the `current_active_session_id` and `Current.user` somehow whenever
    # the current session gets destroyed. When we make that change, we can return the more
    # efficient ||= operator back.
    Current.user = if session[:current_active_session_id].present?
      ActiveSession.find_by(id: session[:current_active_session_id])&.user
    elsif cookies.permanent.encrypted[:remember_token].present?
      ActiveSession.find_by(remember_token: cookies.permanent.encrypted[:remember_token])&.user
    end
  end

  def user_signed_in?
    Current.user.present?
  end
end
