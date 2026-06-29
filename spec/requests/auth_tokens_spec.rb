require "rails_helper"

RSpec.describe "AuthTokens", type: :request do
  describe "POST /auth_tokens" do
    let!(:user) { create(:user, email: "alice@example.com") }

    it "returns token for existing user" do
      post "/auth_tokens", params: { email: " alice@example.com " }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      token = body.dig("data", "token")
      expect(token).to be_present
      expect(JwtCodec.decode(token)[:user_id]).to eq(user.id)
    end

    it "returns not found for unknown user" do
      post "/auth_tokens", params: { email: "unknown@example.com" }, as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("User not found")
    end
  end
end
