require "spec_helper"

describe Authem::User do

  class TestUser < ActiveRecord::Base
    self.table_name = :users
    include Authem::User


    def self.create(email: "joe@example.com", password: "password")
      super(
        email:                 email,
        password:              password,
        password_confirmation: password
      )
    end
  end

  it "downcases email" do
    record = TestUser.new
    record.email = "JOE@EXAMPLE.COM"
    expect(record.email).to eq("joe@example.com")
  end

  subject(:user){ TestUser.create }

  context "#authenticate" do
    it "returns record if password is correct" do
      expect(user.authenticate("password")).to eq(user)
    end

    it "returns false if password is incorrect" do
      expect(user.authenticate("notright")).to be_false
    end

    it "returns false if password is nil" do
      expect(user.authenticate(nil)).to be_false
    end
  end

  context "#password_reset_token" do
    it "generates token on record creation" do
      expect(user.password_reset_token).to be_present
    end
  end

  context "#reset_password" do
    it "changes the password if on successful update" do
      expect{ user.reset_password "123", "123" }.to change{ user.reload.password_digest }
    end

    it "regenerates password reset token on successful update" do
      expect{ user.reset_password "123", "123" }.to change{ user.reload.password_reset_token }
    end

    it "does not change password on error" do
      expect{ user.reset_password "123", "321" }.not_to change{ user.reload.password_digest }
      expect{ user.reset_password "123", "" }.not_to change{ user.reload.password_digest }
      expect{ user.reset_password nil, "321" }.not_to change{ user.reload.password_digest }
      expect{ user.reset_password nil, nil }.not_to change{ user.reload.password_digest }
    end

    it "does not change password reset token on error" do
      expect{ user.reset_password "123", "321" }.not_to change{ user.reload.password_reset_token }
      expect{ user.reset_password "123", "" }.not_to change{ user.reload.password_reset_token }
      expect{ user.reset_password nil, "321" }.not_to change{ user.reload.password_reset_token }
      expect{ user.reset_password nil, nil }.not_to change{ user.reload.password_reset_token }
    end

    it "returns true if when password change is successful" do
      expect(user.reset_password("123", "123")).to be_true
    end

    it "returns false when confirmation does not match" do
      expect(user.reset_password("123", "321")).to be_false
    end

    it "adds an error when confirmation does not match" do
      user.reset_password("123", "321")
      expect(user.errors).to include(:password_confirmation)
    end

    it "adds and error when password is blank" do
      user.reset_password(nil, "")
      expect(user.errors).to include(:password)
    end

    it "returns false when password is blank" do
      expect(user.reset_password("", "")).to be_false
    end
  end

  context "validations" do
    it "allows properly formatted emails" do
      record = TestUser.create(email: "joe@example.com")
      expect(record.errors).not_to include(:email)
    end

    it "validates email presence" do
      record = TestUser.create(email: nil)
      expect(record.errors).to include(:email)
    end

    it "validates email format" do
      record = TestUser.create(email: "joe-at-example-com")
      expect(record.errors).to include(:email)
    end

    it "validates email uniqueness" do
      TestUser.create email: "joe@example.com"
      record = TestUser.create(email: "JOE@EXAMPLE.COM")
      expect(record.errors).to include(:email)
    end
  end
end
