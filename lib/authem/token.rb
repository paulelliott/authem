require 'securerandom'

class Authem::Token
  def self.generate
    SecureRandom.hex(20)
  end
end
