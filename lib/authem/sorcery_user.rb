module Authem::SorceryUser
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do
    attr_accessor :password, :password_confirmation

    before_save :encrypt_password

    def authenticate(password)
      self if crypted_password.present? && ::BCrypt::Password.new(crypted_password) == [password, salt].join
    end

    def encrypt_password
      if password.present?
        self.salt = ::BCrypt::Engine.generate_salt
        self.crypted_password = ::BCrypt::Password.create([password, salt].join)
      end
    end
  end
end
