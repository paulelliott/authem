require "active_support/core_ext/module/delegation"
require "authem/session"
require "authem/errors/ambigous_role"
require "authem/errors/unknown_role"

module Authem
  class Support
    attr_reader :role, :controller

    def initialize(role, controller)
      @role, @controller = role, controller
    end

    def current
      if ivar_defined?
        ivar_get
      else
        ivar_set fetch_subject_by_token
      end
    end

    def sign_in(record, **options)
      check_record! record
      ivar_set record
      auth_session = create_auth_session(record, options)
      save_session auth_session
      save_cookie auth_session if options[:remember]
      auth_session
    end

    def signed_in?
      current.present?
    end

    def sign_out
      ivar_set nil
      Authem::Session.where(role: role_name, token: current_auth_token).delete_all
      cookies.delete key, domain: :all
      session.delete key
    end

    def clear_for(record)
      check_record! record
      sign_out
      Authem::Session.by_subject(record).where(role: role_name).delete_all
    end

    def require
      unless signed_in?
        session[:return_to_url] = request.url unless request.xhr?
        redirect_to sign_in_path
      end
    end

    private

    delegate :name, to: :role, prefix: true

    def check_record!(record)
      fail ArgumentError if record.nil?
    end

    def fetch_subject_by_token
      return if current_auth_token.blank?
      auth_session = get_auth_session_by_token(current_auth_token)
      auth_session && auth_session.refresh
      save_cookie auth_session if cookies.signed[key].present?
      auth_session && auth_session.subject
    end

    def current_auth_token
      session[key] || cookies.signed[key]
    end

    def create_auth_session(record, options)
      Authem::Session.create!(role: role_name, subject: record, ttl: options[:ttl])
    end

    def save_session(auth_session)
      session[key] = auth_session.token
    end

    def save_cookie(auth_session)
      cookie_value = {
        value:   auth_session.token,
        expires: auth_session.expires_at,
        domain:  :all
      }
      cookies.signed[key] = cookie_value
    end

    def get_auth_session_by_token(token)
      Authem::Session.active.find_by(role: role_name, token: token)
    end

    def key
      "_authem_current_#{role_name}"
    end

    def ivar_defined?
      controller.instance_variable_defined?(ivar_name)
    end

    def ivar_set(value)
      controller.instance_variable_set ivar_name, value
    end

    def ivar_get
      controller.instance_variable_get ivar_name
    end

    def ivar_name
      @ivar_name ||= "@_#{key}".to_sym
    end

    def sign_in_path
      controller.send("#{role_name}_sign_in_path")
    end

    # exposing private controller methods
    %i[cookies session redirect_to request].each do |method_name|
      define_method method_name do |*args|
        controller.send(method_name, *args)
      end
    end
  end
end
