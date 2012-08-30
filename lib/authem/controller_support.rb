module Authem::ControllerSupport
  extend ActiveSupport::Concern

  protected

  def sign_in(user, remember_me=true)
    cookies.permanent.signed[:remember_token] = user.remember_token if remember_me
    session[:session_token] = user.session_token
  end

  def sign_out
    cookies[:remember_token] = nil
    reset_session
    @current_user = nil
  end

  def current_user
    if session[:session_token]
      Authem::Config.user_class.where(session_token: session[:session_token].to_s).first
    elsif cookies[:remember_token].present?
      Authem::Config.user_class.where(remember_token: cookies.signed[:remember_token].to_s).first.tap do |user|
        session[:session_token] = user.session_token if user
      end
    end
  end

  def require_user
    unless current_user
      session[:return_to_url] = request.url
      redirect_to Authem::Config.sign_in_path
    end
  end

  def signed_in?
    current_user.present?
  end

  def redirect_back_or_to(url, flash_hash = {})
    url = session[:return_to_url] || url
    session[:return_to_url] = nil
    redirect_to(url, :flash => flash_hash)
  end

  included do
    helper_method :current_user
  end

end
