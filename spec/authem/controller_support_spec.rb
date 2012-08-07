require 'spec_helper'
describe Authem::ControllerSupport do
  subject { controller }

  let!(:user) { ActiveRecordUser.create(:email => 'some@guy.com', :password => 'password') }
  let(:controller) { AuthenticatedController.new }
  let(:cookies) { MockCookies.new }
  let(:session) { {}.with_indifferent_access }
  let(:request) { mock(:request) }

  before do
    user.authem_token!
    controller.stub(:cookies).and_return(cookies)
    controller.stub(:session).and_return(session)
    controller.stub(:request).and_return(request)
  end

  describe '#sign_in' do
    context 'with an email and password' do
      before { controller.send(:sign_in, 'some@guy.com', 'password') }
      its(:current_user) { should == user }
      it { session[:authem_token].should == user.reload.authem_token }
    end

    context 'with a user model' do
      before { controller.send(:sign_in, user) }
      its(:current_user) { should == user }
      it { session[:authem_token].should == user.authem_token }
    end

    context 'without a password' do
      before { controller.send(:sign_in, 'some@guy.com') }
      its(:current_user) { should be_nil }
      it { session[:authem_token].should be_nil }
    end

    context 'remember me' do
      subject { cookies[:remember_me] }
      before { controller.send(:sign_in, 'some@guy.com', 'password', true) }
      it { should == user.reload.authem_token }
    end
  end

  describe '#sign_out' do
    it 'resets the session' do
      controller.should_receive(:clear_session)
      controller.send(:sign_out)
      controller.send(:current_user).should be_nil
    end
  end

  describe '#current_user' do
    subject { controller.send(:current_user) }

    context 'without an established presence' do
      it { should be_nil }
    end

    context 'with a token in the session' do
      before { session[:authem_token] = user.authem_token }
      it { should == user }
    end

    context 'without a remember me token' do
      before { cookies[:remember_me] = "" }
      it { should be_nil }
    end

    context 'with a remember me token' do
      before { cookies[:remember_me] = user.authem_token }
      it { should == user }
      it 'sets the session token' do
        subject
        session[:authem_token].should == user.reload.authem_token
      end
    end

    context 'with an invalid remember me token' do
      before { cookies[:remember_me] = 945 }
      it { should be_nil }
    end
  end

  describe '#signed_in?' do
    subject { controller.send(:signed_in?) }
    before { controller.stub(:current_user).and_return(current_user) }

    context 'when the user is signed in' do
      let(:current_user) { mock }
      it { should be_true }
    end

    context 'when the user is not signed in' do
      let(:current_user) { nil }
      it { should be_false }
    end
  end

  describe '#require_user' do
    context 'with an established user' do
      before { controller.send(:sign_in, user) }
      it 'does not issue a redirect' do
        controller.should_not_receive(:redirect_to)
        controller.send(:require_user)
      end
    end

    context 'without an established user' do
      it 'issues a redirect' do
        request.should_receive(:url)
        controller.should_receive(:redirect_to).with(:sign_in)
        controller.send(:require_user)
      end
    end
  end

  describe '#redirect_back_or_to' do
    context 'with a return_to_url' do
      before { session[:return_to_url] = :dashboard }

      it 'clears and redirects to the return to url' do
        controller.should_receive(:redirect_to).with(:dashboard, :flash => {})
        controller.send :redirect_back_or_to, :somewhere
        session[:return_to_url].should be_nil
      end
    end
  end
end
