module Authem::SorceryUser
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do
    attr_accessor :password, :password_confirmation
    validates_presence_of :password, on: :create
    validates_presence_of :password_confirmation, if: ->(user) { user.password.present? }
    validates_confirmation_of :password, if: ->(user) { user.password.present? }

    before_save :encrypt_password
  end

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
