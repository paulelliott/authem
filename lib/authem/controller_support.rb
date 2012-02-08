module Authem::ControllerSupport
  extend ActiveSupport::Concern

  protected

  def sign_in(email_or_user, password=nil, remember_me=false)
    unless email_or_user.is_a? Authem::Model
      email_or_user = Authem::Config.user_class.authenticate(email_or_user, password)
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
    cookies.permanent.signed[:remember_me] = current_user.authem_token
  end

  def current_user
    @current_user ||= (
      if session[:authem_token]
        Authem::Config.user_class.where(authem_token: session[:authem_token]).first
      elsif cookies[:remember_me].present?
        user = Authem::Config.user_class.where(authem_token: cookies.signed[:remember_me].to_s).first
        establish_presence(user) if user
      end
    )
  end

  def require_user
    unless current_user
      session[:return_to_url] = request.url
      redirect_to Authem::Config.sign_in_path
    end
  end

  def establish_presence(user)
    user.authem_token!
    return_to_url = session[:return_to_url]
    clear_session
    session[:return_to_url] = return_to_url
    session[:authem_token] = user.authem_token
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
  end

  included do
    helper_method :current_user
  end

end
