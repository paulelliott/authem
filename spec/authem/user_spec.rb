require 'spec_helper'

describe Authem::User do
  let(:user_class) { PrimaryStrategyUser }
  let!(:user) { PrimaryStrategyUser.create(email: 'someone@example.com', password: 'password', password_confirmation: 'password') }
  let!(:passwordless_user) { PrimaryStrategyUser.new(email: 'someone@example.com') }

  it_should_behave_like 'base user'

  describe '#authenticate' do
    context 'no password present' do
      subject { passwordless_user.authenticate(nil) }

      it 'returns false' do
        should be_false
      end
    end
  end
end
