module Authem
  module Config
    extend self

    attr_accessor :user_class, :sign_in_path

    Authem::Config.sign_in_path ||= :sign_in

    def configure
      yield self
    end
  end
end
