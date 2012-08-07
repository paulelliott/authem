module Authem
  autoload :BaseUser,    'authem/base_user'
  autoload :User,        'authem/user'
  autoload :SorceryUser, 'authem/sorcery_user'

  autoload :Config, 'authem/config'
  autoload :ControllerSupport, 'authem/controller_support'
  autoload :Token, 'authem/token'

  def self.configure(&block)
    Config.configure(&block)
  end
end
