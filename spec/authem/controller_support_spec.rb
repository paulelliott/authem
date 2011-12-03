require 'spec_helper'

describe Authem::ControllerSupport do
  subject { controller }

  let!(:user) { ActiveRecordUser.create(:email => 'some@guy.com', :password => 'password') }
  let(:controller) { AuthenticatedController.new }
  let(:cookies) { MockCookies.new }
  let(:session) { {}.with_indifferent_access }
  let(:request) { mock(:request) }

  before do
    controller.stub(:cookies).and_return(cookies)
    controller.stub(:session).and_return(session)
    controller.stub(:request).and_return(request)
  end

  describe '#sign_in' do
    context 'with an email and password' do
      before { controller.send(:sign_in, 'some@guy.com', 'password') }
      its(:current_user) { should == user }
      it { session[:user_id].should == user.id }
    end

    context 'with a user model' do
      before { controller.send(:sign_in, user) }
      its(:current_user) { should == user }
      it { session[:user_id].should == user.id }
    end

    context 'without a password' do
      before { controller.send(:sign_in, 'some@guy.com') }
      its(:current_user) { should be_nil }
      it { session[:user_id].should be_nil }
    end

    context 'remember me' do
      subject { cookies[:remember_me] }
      before { controller.send(:sign_in, 'some@guy.com', 'password', true) }
      it { should == user.reload.remember_me_token }
      it { should_not be_nil }
    end
  end

  describe '#sign_out' do
    it 'resets the session' do
      controller.should_receive(:clear_session)
      controller.send(:sign_out)
    end
  end

  describe '#current_user' do
    subject { controller.send(:current_user) }

    context 'without an established presence' do
      it { should be_nil }
    end

    context 'with a user id in the session' do
      before { session[:user_id] = user.id }
      it { should == user }
    end

    context 'without a remember me token' do
      before { cookies[:remember_me] = "" }
      it 'should not search for user by token' do
        user.class.should_not_receive(:find_by_remember_me_token)
        subject
      end
    end

    context 'with a remember me token' do
      before { cookies[:remember_me] = user.remember_me_token }
      it { should == user }
      it 'sets the session user id' do
        subject
        session[:user_id].should == user.id
      end
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
end
