require "active_support/concern"
require "authem/role"

module Authem
  module Controller
    extend ActiveSupport::Concern

    included{ class_attribute :authem_roles }

    module SessionManagementMethods
      def sign_in(model, **options)
        role = options.fetch(:as){ self.class.authem_role_for(model) }
        public_send "sign_in_#{role}", model, options
      end

      def sign_out(model, **options)
        role = options.fetch(:as){ self.class.authem_role_for(model) }
        public_send "sign_out_#{role}"
      end

      def clear_all_sessions_for(model, **options)
        role = options.fetch(:as){ self.class.authem_role_for(model) }
        public_send "clear_all_#{role}_sessions_for", model
      end
    end

    module ClassMethods
      def authem_for(role_name, **options)
        include SessionManagementMethods
        Authem::Role.new(self, role_name, options).setup!
      end

      def authem_role_for(record)
        fail ArgumentError if record.nil?

        matches = authem_roles.select{ |role| record.class == role.klass }

        fail UnknownRoleError, record if matches.empty?
        fail AmbigousRoleError, record => matches unless matches.one?

        matches.first.role_name
      end
    end
  end
end
