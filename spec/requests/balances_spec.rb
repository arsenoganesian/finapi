require "rails_helper"

RSpec.describe "Balances", type: :request do
  let!(:user) { create(:user, balance: 50) }
  let!(:other_user) { create(:user, balance: 75) }
  let(:token) { JwtCodec.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }
  let(:max_amount) { Money::MAX_AMOUNT }

  describe "GET /balance" do
    it "returns current balance" do
      get "/balance", headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.dig("data", "user_id")).to eq(user.external_id)
      expect(body.dig("data", "balance")).to eq("50.00")
    end

    it "returns the authenticated user's balance" do
      get "/balance", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("data", "balance")).to eq("50.00")
      expect(other_user.reload.balance).to eq(BigDecimal("75"))
    end

    it "returns unauthorized without token" do
      get "/balance"

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Missing token")
    end
  end

  describe "PATCH /balance" do
    it "updates user balance" do
      patch "/balance",
        params: { amount: "10.00" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("data", "balance")).to eq("60.00")
    end

    it "does not change another user's balance" do
      patch "/balance",
        params: { amount: "10.00" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:ok)
      expect(user.reload.balance).to eq(BigDecimal("60"))
      expect(other_user.reload.balance).to eq(BigDecimal("75"))
    end

    it "returns validation error for zero amount" do
      patch "/balance",
        params: { amount: "0" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Amount must not be zero")
    end

    it "returns validation error for invalid amount format" do
      patch "/balance",
        params: { amount: "1,01" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Amount format is invalid")
    end

    it "returns validation error for amount with more than two decimal places" do
      patch "/balance",
        params: { amount: "0.009" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Amount format is invalid")
    end

    it "returns validation error when amount exceeds the maximum allowed value" do
      patch "/balance",
        params: { amount: (max_amount + BigDecimal("0.01")).to_s("F") },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Amount exceeds maximum allowed value")
    end
  end
end
