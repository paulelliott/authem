module Authem::ControllerSupport

  protected

  def sign_in(email_or_user, password=nil, remember_me=nil)
    if email_or_user.is_a? String
      email_or_user = Authem::Config.user_class.authenticate(email_or_user, password)
    end
    if email_or_user.is_a? Authem::Model
      establish_presence(email_or_user)
      remember_me! if remember_me
    end
  end

  def sign_out
    clear_session
  end

  def remember_me!
    cookies[:remember_me] = current_user.remember_me_token
  end

  def current_user
    @current_user ||= (
      if session[:user_id]
        Authem::Config.user_class.find(session[:user_id])
      elsif cookies[:remember_me]
        user = Authem::Config.user_class.find_by_remember_me_token(cookies[:remember_me])
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
    clear_session
    session[:user_id] = user.id
    @current_user = user
  end

  def redirect_back_or_to(url, flash_hash = {})
    redirect_to(session[:return_to_url] || url, :flash => flash_hash)
  end

  def clear_session
    cookies[:remember_me] = nil
    return_to_url = session[:return_to_url]
    reset_session
    session[:return_to_url] = return_to_url
  end

end
