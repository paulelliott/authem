require 'spec_helper'

describe Authem::SorceryUser do
  let!(:user) { ActiveRecordUser.create(:email => 'someone@example.com', :password => 'password') }

  describe 'validations' do
    subject { invalid_user }

    context 'when email is not present' do
      let(:invalid_user) { ActiveRecordUser.create(:email => nil) }
      it { should_not be_valid }
    end

    context 'when email has already been taken' do
      let(:invalid_user) { ActiveRecordUser.create(:email => 'someone@example.com', :password => 'password') }
      it { should_not be_valid }
    end
  end

  describe '.authenticate' do
    subject { ActiveRecordUser.authenticate(email, password) }

    context 'with matching credentials' do
      let(:email) { 'someone@example.com' }
      let(:password) { 'password' }
      it { should == user }
    end

    context 'with a non-matching password' do
      let(:email) { 'someone@example.com' }
      let(:password) { 'wordpass' }
      it { should be_nil }
    end

    context 'with a non-matching email' do
      let(:email) { 'someone_else@example.com' }
      let(:password) { 'password' }
      it { should be_nil }
    end
  end

  describe '.find_by_email' do
    subject { ActiveRecordUser.find_by_email(email) }

    context 'with an exact match' do
      let(:email) { 'someone@example.com' }
      it { should == user }
    end

    context 'with a match but different case' do
      let(:email) { 'SomeOne@Example.Com' }
      it { should == user }
    end

    context 'without a match' do
      let(:email) { 'fakedude@example.com' }
      it { should be_nil }
    end
  end

  describe '#encrypt_password' do
    subject { user }

    it 'calls before save' do
      user = ActiveRecordUser.new(:email => 'something@example.com')
      user.should_receive(:encrypt_password)
      user.save
    end

    its(:crypted_password) { should_not == 'something' }
    its(:salt) { should_not be_blank }
    it 'should be duplicatable' do
      user.crypted_password_matches?('something')
    end
  end

  describe '#crypted_password_matches?' do
    subject { user.crypted_password_matches?(password) }

    context 'with the correct password' do
      let(:password) { 'password' }
      it { should be_true }
    end

    context 'with an incorrect password' do
      let(:password) { 'crap' }
      it { should be_false }
    end

    context 'without a crypted password' do
      before { user.crypted_password = nil }
      let(:password) { 'password' }
      it { should be_false }
    end
  end

  describe '#reset_password_token' do
    subject { user.reset_password_token }

    it 'is not generated until requested' do
      user[:reset_password_token].should be_nil
    end

    it 'generates a token when requested' do
      subject.length.should == 40
    end

    it 'does not regenerate when requested again' do
      subject.should == user.reset_password_token
    end
  end

end
