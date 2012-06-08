module Authem::BaseUser
  extend ::ActiveSupport::Concern

  included do
    attr_accessible :email, :password, :password_confirmation

    validates_uniqueness_of :email
    validates_format_of :email, with: /^\S+@\S+$/
    validates_presence_of :password, on: :create
    validates_confirmation_of :password, message: 'should match confirmation'

    def self.find_by_email(email)
      where("LOWER(email) = ?", email.downcase).first
    end

    def remember_token
      self[:remember_token] || generate_token(:remember)
    end

    def reset_password(password, confirmation)
      return false unless password.present?

      self.password = password
      self.password_confirmation = confirmation
      self.reset_password_token = nil
      save
    end

    def reset_password_token!
      generate_token(:reset_password)
    end

    private

    def generate_token(type)
      Authem::Token.generate.tap { |token| update_attribute("#{type}_token", token) }
    end
  end
end
