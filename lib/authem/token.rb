module Authem
  class Token
    def self.generate
      SecureRandom.urlsafe_base64(45)
    end
  end
end
