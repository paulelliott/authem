require 'spec_helper'

describe Authem::Token do

  describe '#generate' do
    subject { Authem::Token.generate }
    its(:length) { should == 40 }

    it 'should be different every time' do
      subject.should_not == Authem::Token.generate
    end
  end

end
