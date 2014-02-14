module Authem
  class UnknownRoleError < StandardError
    def self.build(record)
      new("Unknown authem role: #{record.inspect}")
    end
  end
end
