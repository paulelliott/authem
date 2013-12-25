# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'authem/version'

Gem::Specification.new do |s|
  s.name = "authem"
  s.version = Authem::VERSION
  s.license = "WTFPL"

  s.authors = ["Paul Elliott"]
  s.description = "Authem provides a simple solution for email-based authentication."
  s.email = ["paul@hashrocket.com"]
  s.homepage = "https://github.com/paulelliott/authem"
  s.summary = "Authem authenticates them by email"

  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.markdown)

  s.add_dependency 'activesupport', '~> 4.0.1'
  s.add_dependency 'bcrypt-ruby', '~> 3.1.0'

  s.add_development_dependency 'actionpack', '~> 4.0'
  s.add_development_dependency 'activerecord', '~> 4.0'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry'

  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.markdown Rakefile)
  s.require_path = 'lib'
end
