require "authem/token"

module Authem
  module User
    extend ActiveSupport::Concern

    included do
      has_many :authem_sessions, as: :subject, class_name: "Authem::Session"
      has_secure_password

      validates :email, uniqueness: true, format: /\A\S+@\S+\z/

      before_create{ self.password_reset_token = Authem::Token.generate }
    end

    def email=(value)
      super value.try(:downcase)
    end

    def reset_password(password, confirmation)
      if password.blank?
        errors.add :password, :blank
        return false
      end

      self.password = password
      self.password_confirmation = confirmation

      update_column :password_reset_token, Authem::Token.generate if save
    end
  end
end
