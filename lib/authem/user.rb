module Authem::User
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do
    has_secure_password
  end
end
