require "rails_helper"

RSpec.describe UserSerializer do
  describe ".call" do
    it "serializes user payload" do
      user = build(
        :user,
        id: 42,
        external_id: "11111111-2222-4333-8444-555555555555",
        email: "alice@example.com",
        balance: BigDecimal("12.5")
      )

      expect(described_class.call(user)).to eq(
        data: {
          user_id: "11111111-2222-4333-8444-555555555555",
          email: "alice@example.com",
          balance: "12.50"
        }
      )
    end
  end
end
