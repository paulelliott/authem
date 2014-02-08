require "spec_helper"

describe Authem::Token do
  context ".generate" do
    subject{ described_class.generate }
    it "generates a secure token 60 chars long" do
      expect(subject.length).to eq(60)
    end
  end
end
