require "authem/support"

module Authem
  class Role
    attr_reader :controller, :role_name, :options

    METHODS = %i[current sign_in sign_out clear_for]

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

    def method_mapping
      exposed_methods = %I[current_#{role_name} sign_in_#{role_name}
        sign_out_#{role_name} clear_all_#{role_name}_sessions_for]

      Hash[[METHODS, exposed_methods].transpose]
    end

    def setup!
      authem_role = self
      controller.authem_roles ||= []
      controller.authem_roles.push authem_role
      method_mapping.each do |inner_method, exposed_method|
        controller.instance_eval do
          define_method exposed_method do |*args|
            authem_role.public_send(inner_method, self, *args)
          end
        end
      end
    end
  end
end
