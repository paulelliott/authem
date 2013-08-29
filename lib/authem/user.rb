module Authem::User
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do
    Authem::Config.user_class = self

    has_secure_password

    alias_method :original_authenticate, :authenticate

    def authenticate(password)
      if password.present?
        original_authenticate(password)
      else
        false
      end
    end
  end

end
