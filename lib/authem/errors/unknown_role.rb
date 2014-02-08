module Authem
  class UnknownRoleError < StandardError
    def initialize(record)
      message = "Unknown authem role: #{record.inspect}"
      super message
    end
  end
end
