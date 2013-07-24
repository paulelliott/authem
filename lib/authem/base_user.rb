module Authem::BaseUser
  extend ::ActiveSupport::Concern

  included do
    validates_uniqueness_of :email
    validates_format_of :email, with: /\A\S+@\S+\z/
    validates_presence_of :password, on: :create
    validates_confirmation_of :password
  end

  module ClassMethods
    def find_by_email(email)
      where("LOWER(email) = ?", email.downcase).first
    end
  end

  def remember_token
    self[:remember_token] || generate_token(:remember)
  end

  def session_token
    self[:session_token] || generate_token(:session)
  end

  def reset_password(password, confirmation)
    if password.blank?
      self.errors.add(:password, :blank)
      return false
    end

    reset_password_token = self.reset_password_token

    self.password = password
    self.password_confirmation = confirmation
    self.reset_password_token = nil

    if save
      true
    else
      self.reset_password_token = reset_password_token
      false
    end
  end

  def reset_password_token!
    generate_token(:reset_password)
  end

  private

  def generate_token(type)
    Authem::Token.generate.tap { |token| update_column("#{type}_token", token) }
  end
end
