require 'spec_helper'

describe Authem do
  describe '.configure' do
    it 'passes to the config module' do
      Authem::Config.should_receive(:configure)
      Authem.configure {}
    end
  end
end
