require "rails_helper"

RSpec.describe Auth::IssueTokenService do
  describe ".call" do
    let!(:user) { create(:user, email: "alice@example.com") }

    around do |example|
      original_expiration = Rails.application.config.x.jwt_expiration_seconds
      example.run
      Rails.application.config.x.jwt_expiration_seconds = original_expiration
    end

    it "issues token for existing normalized email" do
      token = described_class.call(email: " ALICE@example.com ")

      payload = JwtCodec.decode(token)
      expect(payload[:user_id]).to eq(user.id)
      expect(payload[:exp]).to be > Time.current.to_i
    end

    it "uses configured jwt expiration in seconds" do
      Rails.application.config.x.jwt_expiration_seconds = 120

      token = described_class.call(email: user.email)
      payload = JwtCodec.decode(token)

      expect(payload[:exp]).to be_between(Time.current.to_i + 119, Time.current.to_i + 121)
    end

    it "raises when user is not found" do
      expect do
        described_class.call(email: "missing@example.com")
      end.to raise_error(ActiveRecord::RecordNotFound, "User not found")
    end
  end
end
