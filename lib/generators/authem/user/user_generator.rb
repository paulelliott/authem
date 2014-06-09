require "rails/generators/active_record/model/model_generator"

module Authem
  class UserGenerator < ActiveRecord::Generators::ModelGenerator
    source_root File.expand_path("../templates", __FILE__)

    private

    def migration_template(_, migration_file_name)
      super "create_table_migration.rb", migration_file_name
    end
  end
end
