require "authem/railtie"
require "active_support/all"

module Authem
  autoload :Controller,         "authem/controller"
  autoload :Role,               "authem/role"
  autoload :Session,            "authem/session"
  autoload :Support,            "authem/support"
  autoload :Token,              "authem/token"
  autoload :User,               "authem/user"
  autoload :AmbigousRoleError,  "authem/errors/ambigous_role"
  autoload :UnknownRoleError,   "authem/errors/unknown_role"
end
