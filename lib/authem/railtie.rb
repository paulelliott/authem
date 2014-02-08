require "authem/controller"
require "rails/railtie"

module Authem
  class Railtie < ::Rails::Railtie
    initializer "authem.controller" do
      ActiveSupport.on_load :action_controller do
        include Authem::Controller
      end
    end
  end
end
