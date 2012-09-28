require 'rails/generators/base'

module Authem
  class ModelGenerator < Rails::Generators::Base

    argument :model_name, type: :string, default: "user"

    def generate_model
      generate("model #{model_name} email:string, password_digest:string, reset_password_token:string, session_token:string")
    end

    def update_model_to_include_authem
      insert_into_file "app/models/#{model_name}.rb", "\n  include Authem::User\n\n", after: "class #{model_name.camelize} < ActiveRecord::Base\n"
    end

    def add_initializer
      create_file 'config/initializers/authem.rb' do
        %Q(Authem.configure do |config|\n  config.user_class = #{model_name.camelize}\nend)
      end
    end

  end
end
