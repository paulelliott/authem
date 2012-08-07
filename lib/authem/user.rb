module Authem::User
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do
    Authem::Config.user_class = self

    has_secure_password
  end
end
