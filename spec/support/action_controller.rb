require 'action_controller'

class AuthenticatedController < ActionController::Base
  include Authem::ControllerSupport

  def reset_session
    session.clear
  end
end

class MockCookies < Hash
  def permanent; self end
  def signed; self end
end
