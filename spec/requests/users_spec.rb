require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    it "creates user" do
      post "/users", params: { user: { email: "new@example.com" } }, as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body.dig("data", "user_id")).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/)
      expect(body.dig("data", "id")).to be_nil
      expect(body.dig("data", "email")).to eq("new@example.com")
      expect(body.dig("data", "balance")).to eq("0.00")
    end

    it "returns error for invalid email" do
      post "/users", params: { user: { email: "bad" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Email format is invalid")
    end
  end
end
