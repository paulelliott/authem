require 'bcrypt'

module Authem::Model
  extend ::ActiveSupport::Concern

  included do
    Authem::Config.user_class = self

    attr_accessor :password, :password_confirmation

    attr_protected :crypted_password, :salt, :reset_password_token, :remember_me_token

    validates_confirmation_of :password
    validate :email, :presence => true, :uniqueness => true

    def self.find_by_email(email)
      where("upper(email) = ?", email.upcase).first
    end

    def self.find_by_remember_me_token(remember_me_token)
      where(:remember_me_token => remember_me_token).first
    end

    def self.find_by_reset_password_token(reset_password_token)
      where(:reset_password_token => reset_password_token).first
    end

    before_save :encrypt_password

    def self.authenticate(email, password)
      user = find_by_email(email)
      user if user && user.crypted_password_matches?(password)
    end
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

  def remember_me_token
    update_attribute(:remember_me_token, Authem::Token.generate) if self[:remember_me_token].blank?
    self[:remember_me_token]
  end

  def reset_password_token
    update_attribute(:reset_password_token, Authem::Token.generate) if self[:reset_password_token].blank?
    self[:reset_password_token]
  end

end
