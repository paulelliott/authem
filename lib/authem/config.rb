module Authem
  module Config
    extend self

    attr_accessor :sign_in_path

    Authem::Config.sign_in_path ||= :sign_in

    def configure
      yield self
    end

    def user_class
      @user_class.constantize
    end

    def user_class=(user_class)
      @user_class = user_class.to_s
    end
  end
end
