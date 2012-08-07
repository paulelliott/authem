shared_examples 'base user' do

  describe 'validations' do
    subject { invalid_user }

    context 'when email is not present' do
      let(:invalid_user) { user_class.create(email: nil) }
      its(:errors) { should include(:email) }
    end

    context 'when email has already been taken' do
      let(:invalid_user) { user_class.create(email: 'someone@example.com') }
      its(:errors) { should include(:email) }
    end

    context 'when email has an invalid format' do
      let(:invalid_user) { user_class.create(email: 'someone') }
      its(:errors) { should include(:email) }
    end
  end

  describe '.authenticate' do
    subject { user.authenticate(password) }

    context 'with matching credentials' do
      let(:password) { 'password' }
      it { should == user }
    end

    context 'with a non-matching password' do
      let(:password) { 'wordpass' }
      it { should be_false }
    end
  end

  describe '.find_by_email' do
    subject { user_class.find_by_email(email) }

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

  describe '#remember_token' do
    subject { user.remember_token }

    it 'starts off blank' do
      user[:remember_token].should be_nil
    end

    it 'generates a token when requested' do
      subject.length.should == 40
    end

    it 'does not regenerate when requested again' do
      subject.should == user.remember_token
    end
  end

  describe '#reset_password' do
    subject { user.reset_password(password, confirmation) }
    let(:confirmation) { password }

    context 'with a blank password' do
      let(:password) { '   ' }
      it { should be_false }
    end

    context 'with non-matching confirmation' do
      before { subject }
      let(:password) { 'password' }
      let(:confirmation) { 'wrong' }
      it { should be_false }
      it 'should have an error on password' do
        user.errors.should include(:password)
      end
    end

    context 'with matching confirmation' do
      before { subject }
      let(:password) { 'password' }
      it { should be_true }
      it 'clears the reset password token' do
        user.reset_password_token.should be_nil
      end
    end
  end

  describe '#reset_password_token!' do
    subject { user.reset_password_token! }

    it 'is not generated until requested' do
      user[:reset_password_token].should be_nil
    end

    it 'generates a token when requested' do
      subject.length.should == 40
    end

    it 'regenerates when requested again' do
      subject.should_not == user.reset_password_token!
    end
  end

end
