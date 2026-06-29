require "rails_helper"

RSpec.describe "Transfers", type: :request do
  let!(:sender) { create(:user, balance: 100) }
  let!(:recipient) { create(:user, balance: 20) }
  let!(:other_user) { create(:user, balance: 300) }
  let(:token) { JwtCodec.encode(user_id: sender.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "POST /transfers" do
    it "transfers between users" do
      post "/transfers",
        params: {
          transfer: {
            recipient_email: recipient.email,
            amount: "25.00"
          }
        },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.dig("data", "user_id")).to eq(sender.external_id)
      expect(body.dig("data", "balance")).to eq("75.00")
    end

    it "ignores a spoofed sender id and uses the authenticated user" do
      post "/transfers",
        params: {
          transfer: {
            from_user_id: other_user.id,
            recipient_email: recipient.email,
            amount: "25.00"
          }
        },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:ok)
      expect(sender.reload.balance).to eq(BigDecimal("75"))
      expect(other_user.reload.balance).to eq(BigDecimal("300"))
      expect(recipient.reload.balance).to eq(BigDecimal("45"))
    end

    it "returns business error for insufficient funds" do
      post "/transfers",
        params: {
          transfer: {
            recipient_email: recipient.email,
            amount: "1000.00"
          }
        },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Insufficient funds for transfer")
    end

    it "returns not found for unknown recipient email" do
      post "/transfers",
        params: {
          transfer: {
            recipient_email: "missing@example.com",
            amount: "10.00"
          }
        },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Recipient not found")
    end
  end
end
