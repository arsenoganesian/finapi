require "rails_helper"

RSpec.describe JwtCodec do
  describe ".encode" do
    include ActiveSupport::Testing::TimeHelpers

    it "adds default expiration when exp is not provided" do
      ttl = Rails.application.config.x.jwt_expiration_seconds

      travel_to(Time.zone.parse("2026-01-01 12:00:00 UTC")) do
        token = described_class.encode(user_id: 42)
        payload = described_class.decode(token)

        expect(payload[:user_id]).to eq(42)
        expect(payload[:exp]).to eq(Time.current.to_i + ttl)
      end
    end

    it "keeps provided expiration" do
      custom_expiration = 2.hours.from_now.to_i

      token = described_class.encode(user_id: 7, exp: custom_expiration)
      payload = described_class.decode(token)

      expect(payload[:user_id]).to eq(7)
      expect(payload[:exp]).to eq(custom_expiration)
    end
  end

  describe ".decode" do
    it "raises DecodeError for malformed token" do
      expect do
        described_class.decode("not-a-jwt")
      end.to raise_error(JwtCodec::DecodeError)
    end
  end
end
