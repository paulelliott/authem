require "authem/support"

module Authem
  class Role
    attr_reader :controller, :role_name, :options

    METHODS = %i[current sign_in signed_in? require sign_out clear_for]

    METHODS.each do |method_name|
      define_method method_name do |controller, *args|
        Support.new(self, controller).public_send(method_name, *args)
      end
    end

    def initialize(controller, role_name, **options)
      @controller, @role_name, @options = controller, role_name.to_s, options
    end

    def klass
      @klass ||= options.fetch(:model){ role_name.classify.constantize }
    end

    def setup!
      setup_controller_settings
      setup_controller_instance_methods
    end

    private

    def setup_controller_settings
      controller.authem_roles ||= []
      controller.authem_roles.push self
    end

    def setup_controller_instance_methods
      authem_role = self
      mapping = method_mapping
      name = role_name

      controller.instance_eval do
        mapping.each do |inner_method, exposed_method|
          define_method exposed_method do |*args|
            authem_role.public_send(inner_method, self, *args)
          end
        end

        define_method "#{name}_sign_in_path" do
          :root
        end
      end

    end

    def method_mapping
      exposed_methods = %I[current_#{role_name} sign_in_#{role_name}
        #{role_name}_signed_in? require_#{role_name} sign_out_#{role_name}
        clear_all_#{role_name}_sessions_for]

      Hash[[METHODS, exposed_methods].transpose]
    end
  end
end
