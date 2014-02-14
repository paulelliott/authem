require "spec_helper"

describe Authem::Controller do
  class User < ActiveRecord::Base
    self.table_name = :users
  end

  module MyNamespace
    class SuperUser < ActiveRecord::Base
      self.table_name = :users
    end
  end

  class BaseController
    include Authem::Controller

    class << self
      def helper_methods_list
        @helper_methods_list ||= []
      end

      def helper_method(*methods)
        helper_methods_list.concat methods
      end
    end

    def clear_session!
      session.clear
    end

    def request
      double("Request").stub(url: request_url)
    end

    def reloaded
      self.class.new.tap do |controller|
        controller.stub(
          session: session,
          cookies: cookies
        )
      end
    end

    private

    def session
      @_session ||= HashWithIndifferentAccess.new
    end

    def cookies
      @_cookies ||= Cookies.new
    end
  end

  class Cookies < HashWithIndifferentAccess
    attr_reader :expires_at

    def permanent
      self
    end

    alias_method :signed, :permanent

    def []=(key, value)
      if value.kind_of?(Hash) && value.key?(:expires)
        @expires_at = value[:expires]
        super key, value.fetch(:value)
      else
        super
      end
    end

    def delete(key, *)
      super key
    end
  end

  def build_controller
    controller_klass.new
  end

  let(:controller){ build_controller.tap{ |c| c.stub(request: request) }}
  let(:view_helpers){ controller_klass.helper_methods_list }
  let(:cookies){ controller.send(:cookies) }
  let(:session){ controller.send(:session) }
  let(:reloaded_controller){ controller.reloaded }
  let(:request_url){ "http://example.com/foo" }
  let(:request){ double("Request").tap{ |r| r.stub(url: request_url, xhr?: false) }}

  context "with one role" do
    let(:user){ User.create(email: "joe@example.com") }
    let(:controller_klass){ Class.new(BaseController){ authem_for :user }}

    it "has current_user method" do
      expect(controller).to respond_to(:current_user)
    end

    it "has sign_in_user method" do
      expect(controller).to respond_to(:sign_in_user)
    end

    it "has clear_all_user_sessions_for method" do
      expect(controller).to respond_to(:clear_all_user_sessions_for)
    end

    it "has require_user method" do
      expect(controller).to respond_to(:require_user)
    end

    it "has user_signed_in? method" do
      expect(controller).to respond_to(:user_signed_in?)
    end

    it "has user_sign_in_path method with default value" do
      expect(controller).to respond_to(:user_sign_in_path)
      expect(controller.send(:user_sign_in_path)).to eq(:root)
    end

    it "has redirect_back_or_to method" do
      expect(controller).to respond_to(:redirect_back_or_to)
    end

    it "can clear all sessions using clear_all_sessions method" do
      expect(controller).to receive(:clear_all_user_sessions_for).with(user)
      controller.clear_all_sessions_for user
    end

    it "defines view helpers" do
      expect(view_helpers).to include(:current_user)
      expect(view_helpers).to include(:user_signed_in?)
    end

    it "raises error when calling clear_all_sessions_for with nil" do
      expect{ controller.clear_all_sessions_for nil }.to raise_error(ArgumentError)
      expect{ controller.clear_all_user_sessions_for nil }.to raise_error(ArgumentError)
    end

    it "can sign in user using sign_in_user method" do
      controller.sign_in_user user
      expect(controller.current_user).to eq(user)
      expect(reloaded_controller.current_user).to eq(user)
    end

    it "can show status of current session with user_signed_in? method" do
      expect{ controller.sign_in user }.to change(controller, :user_signed_in?).from(false).to(true)
      expect{ controller.sign_out user }.to change(controller, :user_signed_in?).from(true).to(false)
    end

    it "can store session token in a cookie when :remember option is used" do
      expect{ controller.sign_in user, remember: true }.to change(cookies, :size).by(1)
    end

    it "can require authenticated user with require_user method" do
      controller.stub(user_sign_in_path: :custom_path)
      expect(controller).to receive(:redirect_to).with(:custom_path)
      expect{ controller.require_user }.to change{ session[:return_to_url] }.from(nil).to(request_url)
    end

    it "sets cookie expiration date when :remember options is used" do
      controller.sign_in user, remember: true, ttl: 1.week
      expect(cookies.expires_at).to be_within(1).of(1.week.to_i.from_now)
    end

    it "can restore user from cookie when session is lost" do
      controller.sign_in user, remember: true
      controller.clear_session!
      expect(controller.reloaded.current_user).to eq(user)
    end

    it "does not use cookies by default" do
      expect{ controller.sign_in user }.not_to change(cookies, :size)
    end

    it "returns session object on sign in" do
      result = controller.sign_in_user(user)
      expect(result).to be_kind_of(::Authem::Session)
    end

    it "allows to specify ttl using sign_in_user with ttl option" do
      session = controller.sign_in_user(user, ttl: 40.minutes)
      expect(session.ttl).to eq(40.minutes)
    end

    it "forgets user after session has expired" do
      session = controller.sign_in(user)
      session.update_column :expires_at, 1.minute.ago
      expect(reloaded_controller.current_user).to be_nil
    end

    it "renews session ttl each time it is used" do
      session = controller.sign_in(user, ttl: 1.day)
      session.update_column :expires_at, 1.minute.from_now
      reloaded_controller.current_user
      expect(session.reload.expires_at).to be_within(1).of(1.day.to_i.from_now)
    end

    it "renews cookie expiration date each time it is used" do
      session = controller.sign_in(user, ttl: 1.day, remember: true)
      session.update_column :ttl, 1.month
      reloaded_controller.current_user
      expect(cookies.expires_at).to be_within(1).of(1.month.to_i.from_now)
    end

    it "can sing in using sign_in method" do
      expect(controller).to receive(:sign_in_user).with(user, {})
      controller.sign_in user
    end

    it "allows to specify ttl using sign_in method with ttl option" do
      session = controller.sign_in(user, ttl: 40.minutes)
      expect(session.ttl).to eq(40.minutes)
    end

    it "raises an error when trying to sign in unknown model" do
      model = MyNamespace::SuperUser.create(email: "admin@example.com")
      message = "Unknown authem role: #{model.inspect}"
      expect{ controller.sign_in model }.to raise_error(Authem::UnknownRoleError, message)
    end

    it "raises an error when trying to sign in nil" do
      expect{ controller.sign_in nil }.to raise_error(ArgumentError)
      expect{ controller.sign_in_user nil }.to raise_error(ArgumentError)
    end

    it "has sign_out_user method" do
      expect(controller).to respond_to(:sign_out_user)
    end

    context "when user is signed in" do
      let(:sign_in_options){ Hash.new }

      before do
        controller.sign_in user, sign_in_options
        expect(controller.current_user).to eq(user)
      end

      after do
        expect(controller.current_user).to be_nil
        expect(reloaded_controller.current_user).to be_nil
      end

      it "can sign out using sign_out_user method" do
        controller.sign_out_user
      end

      it "can sign out using sign_out method" do
        controller.sign_out user
      end

      context "with cookies" do
        let(:sign_in_options){{ remember: true }}

        after{ expect(cookies).to be_empty }

        it "removes session token from cookies on sign out" do
          controller.sign_out_user
        end
      end
    end

    context "with multiple sessions across devices" do
      let(:first_device){ controller }
      let(:second_device){ build_controller }

      before do
        first_device.sign_in user
        second_device.sign_in user
      end

      it "signs out all currently active sessions on all devices" do
        expect{ first_device.clear_all_user_sessions_for user }.to change(Authem::Session, :count).by(-2)
        expect(second_device.reloaded.current_user).to be_nil
      end
    end

    it "raises an error when calling sign_out with nil" do
      expect{ controller.sign_out nil }.to raise_error(ArgumentError)
    end

    it "persists session in database" do
      expect{ controller.sign_in user }.to change(Authem::Session, :count).by(1)
    end

    it "removes database session on sign out" do
      controller.sign_in user
      expect{ controller.sign_out user }.to change(Authem::Session, :count).by(-1)
    end
  end

  context "with multiple roles" do
    let(:admin){ MyNamespace::SuperUser.create(email: "admin@example.com") }
    let(:controller_klass) do
      Class.new(BaseController) do
        authem_for :user
        authem_for :admin, model: MyNamespace::SuperUser
      end
    end

    it "has current_admin method" do
      expect(controller).to respond_to(:current_admin)
    end

    it "has sign_in_admin method" do
      expect(controller).to respond_to(:sign_in_admin)
    end

    it "can sign in admin using sign_in_admin method" do
      controller.sign_in_admin admin
      expect(controller.current_admin).to eq(admin)
      expect(reloaded_controller.current_admin).to eq(admin)
    end

    it "can sign in using sing_in method" do
      expect(controller).to receive(:sign_in_admin).with(admin, {})
      controller.sign_in admin
    end

    context "with signed in user and admin" do
      let(:user){ User.create(email: "joe@example.com") }

      before do
        controller.sign_in_user user
        controller.sign_in_admin admin
      end

      after do
        expect(controller.current_admin).to eq(admin)
        expect(reloaded_controller.current_admin).to eq(admin)
      end

      it "can sign out user separately from admin using sign_out_user" do
        controller.sign_out_user
      end

      it "can sign out user separately from admin using sign_out" do
        controller.sign_out user
      end
    end
  end

  context "multiple roles with same model class" do
    let(:user){ User.create(email: "joe@example.com") }
    let(:customer){ User.create(email: "shmoe@example.com") }
    let(:controller_klass) do
      Class.new(BaseController) do
        authem_for :user
        authem_for :customer, model: User
      end
    end

    it "can sign in user separately from customer" do
      controller.sign_in_user user
      expect(controller.current_user).to eq(user)
      expect(controller.current_customer).to be_nil
      expect(reloaded_controller.current_user).to eq(user)
      expect(reloaded_controller.current_customer).to be_nil
    end

    it "can sign in customer and user separately" do
      controller.sign_in_user user
      controller.sign_in_customer customer
      expect(controller.current_user).to eq(user)
      expect(controller.current_customer).to eq(customer)
      expect(reloaded_controller.current_user).to eq(user)
      expect(reloaded_controller.current_customer).to eq(customer)
    end

    it "raises the error when sign in can't guess the model properly" do
      message = "Ambigous match for #{user.inspect}: user, customer"
      expect{ controller.sign_in user }.to raise_error(Authem::AmbigousRoleError, message)
    end

    it "allows to specify role with special :as option" do
      expect(controller).to receive(:sign_in_customer).with(user, as: :customer)
      controller.sign_in user, as: :customer
    end

    it "raises the error when sign out can't guess the model properly" do
      message = "Ambigous match for #{user.inspect}: user, customer"
      expect{ controller.sign_out user }.to raise_error(Authem::AmbigousRoleError, message)
    end
  end

  context "redirect after authentication" do
    let(:controller_klass){ Class.new(BaseController){ authem_for :user }}

    context "with saved url" do
      before{ session[:return_to_url] = :my_url }

      it "redirects back to saved url if it's available" do
        expect(controller).to receive(:redirect_to).with(:my_url, notice: "foo")
        controller.redirect_back_or_to :root, notice: "foo"
      end

      it "removes values from session after successful redirect" do
        expect(controller).to receive(:redirect_to).with(:my_url, {})
        expect{ controller.redirect_back_or_to :root }.to change{ session[:return_to_url] }.from(:my_url).to(nil)
      end
    end

    it "redirects to specified url if there is no saved value" do
      expect(controller).to receive(:redirect_to).with(:root, notice: "foo")
      controller.redirect_back_or_to :root, notice: "foo"
    end

  end
end
