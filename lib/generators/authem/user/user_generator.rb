require "rails/generators/base"

module Authem
  class UserGenerator < Rails::Generators::Base
    argument :model_name, type: :string, default: "user"

    def generate_model
      generate "model #{model_name} email:string password_digest:string password_reset_token:string"
    end

    def update_model_to_include_authem
      insert_into_file "app/models/#{model_name}.rb",
        "  include Authem::User\n\n",
        after: "class #{model_name.classify} < ActiveRecord::Base\n"
    end
  end
end
