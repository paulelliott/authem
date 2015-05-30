require "bundler/setup"
require "rails"
require "authem"

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each(&method(:require))
