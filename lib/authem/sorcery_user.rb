require 'bcrypt'

module Authem::SorceryUser
  extend ::ActiveSupport::Concern

  included do
    attr_accessor :password, :password_confirmation

    attr_protected :crypted_password, :salt, :reset_password_token, :authem_token

    validates_confirmation_of :password
    validates :email, :presence => true, :uniqueness => true

    def self.find_by_email(email)
      where("upper(email) = ?", email.upcase).first
    end

    before_save :encrypt_password

    def self.authenticate(email, password)
      user = find_by_email(email)
      user if user && user.crypted_password_matches?(password)
    end
  end

  def authem_token!
    update_attribute(:authem_token, Authem::Token.generate)
  end

  def crypted_password_matches?(password)
    crypted_password.present? && ::BCrypt::Password.new(crypted_password) == [password, salt].join
  end

  def encrypt_password
    if password.present?
      self.salt = ::BCrypt::Engine.generate_salt
      self.crypted_password = ::BCrypt::Password.create([password, salt].join)
    end
  end

  def reset_password_token
    update_attribute(:reset_password_token, Authem::Token.generate) if self[:reset_password_token].blank?
    self[:reset_password_token]
  end

end
