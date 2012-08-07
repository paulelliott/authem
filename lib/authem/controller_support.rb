module Authem::ControllerSupport
  extend ActiveSupport::Concern

  protected

  def sign_in(email_or_user, password=nil, remember_me=false)
    if email_or_user.is_a? String
      user = Authem::Config.user_class.find_by_email(email_or_user)
      email_or_user = user.authenticate(password) ? user : nil
    end
    if email_or_user
      establish_presence(email_or_user)
      remember_me! if remember_me
      email_or_user
    end
  end

  def sign_out
    clear_session
  end

  def remember_me!
    cookies.permanent.signed[:remember_me] = current_user.remember_token
  end

  def current_user
    @current_user ||= (
      if session[:remember_token]
        Authem::Config.user_class.where(remember_token: session[:remember_token]).first
      elsif cookies[:remember_me].present?
        user = Authem::Config.user_class.where(remember_token: cookies.signed[:remember_me].to_s).first
        establish_presence(user) if user
      end
    )
  end

  def signed_in?
    !!current_user
  end

  def require_user
    unless current_user
      session[:return_to_url] = request.url
      redirect_to Authem::Config.sign_in_path
    end
  end

  def establish_presence(user)
    return_to_url = session[:return_to_url]
    clear_session
    session[:return_to_url] = return_to_url
    session[:remember_token] = user.remember_token
    @current_user = user
  end

  def redirect_back_or_to(url, flash_hash = {})
    url = session[:return_to_url] || url
    session[:return_to_url] = nil
    redirect_to(url, :flash => flash_hash)
  end

  def clear_session
    cookies[:remember_me] = nil
    reset_session
    @current_user = nil
  end

  included do
    helper_method :current_user
  end

end
