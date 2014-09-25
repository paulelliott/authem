# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authem/version'

Gem::Specification.new do |spec|
  spec.name                  = "authem"
  spec.version               = Authem::VERSION
  spec.authors               = ["Paul Elliott", "Pavel Pravosud"]
  spec.email                 = ["paul@codingfrontier.com", "pavel@pravosud.com"]
  spec.summary               = "Authem authenticates them by email"
  spec.description           = "Authem provides a simple solution for email-based authentication"
  spec.homepage              = "https://github.com/paulelliott/authem"
  spec.license               = "MIT"

  spec.required_ruby_version = ">= 1.9.3"

  spec.files                 = `git ls-files`.split($/)
  spec.test_files            = spec.files.grep("spec")
  spec.require_path          = "lib"

  spec.add_dependency "activesupport",  ">= 4.0.4"
  spec.add_dependency "railties",       "~> 4.0"
  spec.add_dependency "bcrypt",         "~> 3.1"
end
