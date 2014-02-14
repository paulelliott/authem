require "authem/support"

module Authem
  class Role
    attr_reader :controller, :name, :options

    METHODS = %i[current sign_in signed_in? require sign_out clear_for]

    METHODS.each do |method_name|
      define_method method_name do |controller, *args|
        Support.new(self, controller).public_send(method_name, *args)
      end
    end

    def initialize(controller, name, **options)
      @controller, @name, @options = controller, name.to_s, options
    end

    def klass
      @klass ||= options.fetch(:model){ name.classify.constantize }
    end

    def setup!
      setup_controller_settings
      setup_controller_instance_methods
      setup_view_helpers
    end

    private

    def setup_controller_settings
      controller.authem_roles ||= []
      controller.authem_roles += [self]
    end

    def setup_controller_instance_methods
      role = self

      method_mapping.each do |inner_method, exposed_method|
        define_controller_method exposed_method do |*args|
          role.public_send(inner_method, self, *args)
        end
      end

      define_controller_method "#{role.name}_sign_in_path" do
        :root
      end
    end

    def setup_view_helpers
      controller.helper_method *%I[current_#{name} #{name}_signed_in?]
    end

    def define_controller_method(*args, &block)
      controller.instance_eval{ define_method *args, &block }
    end

    def method_mapping
      exposed_methods = %I[current_#{name} sign_in_#{name}
        #{name}_signed_in? require_#{name} sign_out_#{name}
        clear_all_#{name}_sessions_for]

      Hash[[METHODS, exposed_methods].transpose]
    end
  end
end