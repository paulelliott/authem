require 'spec_helper'

describe Authem::User do
  let(:user_class) { PrimaryStrategyUser }
  let!(:user) { PrimaryStrategyUser.create(email: 'someone@example.com', password: 'password', password_confirmation: 'password') }

  it_should_behave_like 'base user'
end
