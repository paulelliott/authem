require 'spec_helper'

describe Authem::SorceryUser do
  let(:user_class) { SorceryStrategyUser }
  let!(:user) { SorceryStrategyUser.create(email: 'someone@example.com', password: 'password') }

  it_should_behave_like 'base user'

  describe '#encrypt_password' do
    subject { user }

    its(:crypted_password) { should_not == 'password' }
    its(:salt) { should_not be_blank }
    it 'should be duplicatable' do
      user.authenticate('password').should == user
    end
  end
end
