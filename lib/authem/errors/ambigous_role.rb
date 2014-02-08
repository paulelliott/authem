module Authem
  class AmbigousRoleError < StandardError
    def initialize(options)
      record = options.keys.first
      matches = options[record].map(&:role_name)
      message = "Ambigous match for #{record.inspect}: #{matches * ', '}"
      super message
    end
  end
end
