require "rails/generators/active_record"

module Authem
  class SessionGenerator < ActiveRecord::Generators::Base
    argument :name, type: :string, default: 'unused but required by activerecord'
    source_root File.expand_path("../templates", __FILE__)

    def copy_session_migration
      migration_template "create_sessions.rb", "db/migrate/create_authem_sessions.rb"
    end
  end
end
