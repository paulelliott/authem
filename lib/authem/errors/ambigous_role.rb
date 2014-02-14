module Authem
  class AmbigousRoleError < StandardError
    def self.build(record, roles)
      role_names = roles.map(&:name) * ", "
      new("Ambigous match for #{record.inspect}: #{role_names}")
    end
  end
end
