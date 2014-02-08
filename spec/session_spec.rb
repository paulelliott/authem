require "spec_helper"

describe Authem::Session do
  class User < ActiveRecord::Base
    self.table_name = :users
  end

  let(:user){ User.create(email: "joe@example.com") }
  let(:role){ :user }

  it "generates secure token on creation" do
    expect(Authem::Token).to receive(:generate).and_return("a secure token")
    model = described_class.create(role: role, subject: user)
    expect(model.token).to eq("a secure token")
  end

  it "set expires_at attribute according to ttl" do
    model = described_class.create(role: role, subject: user, ttl: 30.minutes)
    expect(model.expires_at).to be_within(1).of(30.minutes.to_i.from_now)
  end

  it "uses default ttl if value is not provided" do
    model = described_class.create(role: role, subject: user)
    expect(model.expires_at).to be_within(1).of(30.days.to_i.from_now)
  end

  context "scopes" do
    def create_session_with_expiration(expires_at)
      described_class.create(
        role:       role,
        subject:    user,
        expires_at: expires_at
      )
    end

    let!(:expired_session){ create_session_with_expiration(1.day.ago) }
    let!(:active_session){ create_session_with_expiration(1.week.from_now) }
    let(:active_scope){ described_class.active }
    let(:expired_scope){ described_class.expired }

    specify ".active filters out expired sessions" do
      expect(active_scope).to include(active_session)
      expect(active_scope).not_to include(expired_session)
    end

    specify ".expired filters out active sessions" do
      expect(expired_scope).to include(expired_session)
      expect(expired_scope).not_to include(active_session)
    end
  end

end
