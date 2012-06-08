module Authem
  autoload :BaseUser,    'authem/base_user'
  autoload :User,        'authem/user'

  autoload :Config, 'authem/config'
  autoload :ControllerSupport, 'authem/controller_support'
  autoload :Model, 'authem/model'
  autoload :Token, 'authem/token'

  def self.configure(&block)
    Config.configure(&block)
  end
end
