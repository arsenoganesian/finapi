require "rails_helper"

RSpec.describe Auth::AuthorizeRequestService do
  describe ".call" do
    let!(:user) { create(:user) }

    it "returns user for valid bearer token" do
      token = JwtCodec.encode(user_id: user.id)

      result = described_class.call(authorization_header: "Bearer #{token}")
      expect(result.id).to eq(user.id)
    end

    it "raises unauthorized for missing token" do
      expect do
        described_class.call(authorization_header: nil)
      end.to raise_error(ServiceError) { |error|
        expect(error.message).to eq("Missing token")
        expect(error.status).to eq(:unauthorized)
      }
    end

    it "raises decode error for malformed token" do
      expect do
        described_class.call(authorization_header: "Bearer bad-token")
      end.to raise_error(JwtCodec::DecodeError)
    end

    it "raises decode error for expired token" do
      token = JwtCodec.encode(user_id: user.id, exp: 1.minute.ago.to_i)

      expect do
        described_class.call(authorization_header: "Bearer #{token}")
      end.to raise_error(JwtCodec::DecodeError, "Signature has expired")
    end

    it "raises unauthorized when token subject does not exist" do
      token = JwtCodec.encode(user_id: 999_999)

      expect do
        described_class.call(authorization_header: "Bearer #{token}")
      end.to raise_error(ServiceError) { |error|
        expect(error.message).to eq("Invalid token subject")
        expect(error.status).to eq(:unauthorized)
      }
    end
  end
end
