require 'spec_helper'

describe Authem::Config do
  describe '.configure' do
    context 'defaults' do
      its(:sign_in_path) { should == :sign_in }
    end

    context 'with stuff set' do
      before do
        Authem::Config.configure do |config|
          config.sign_in_path = :come_on_in_folks
        end
      end

      its(:sign_in_path) { should == :come_on_in_folks }
    end

    after do
      Authem::Config.sign_in_path = :sign_in
    end
  end
end
