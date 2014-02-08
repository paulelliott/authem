require "rails/generators/base"
require "rails/generators/active_record/migration"

module Authem
  class SessionGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration
    source_root File.expand_path("../templates", __FILE__)

    def copy_session_migration
      migration_template "create_sessions.rb", "db/migrate/create_authem_sessions.rb"
    end
  end
end
