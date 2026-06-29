require "rails_helper"

RSpec.describe BalanceSerializer do
  describe ".call" do
    it "serializes balance payload" do
      user = build(
        :user,
        id: 7,
        external_id: "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee",
        balance: BigDecimal("50")
      )

      expect(described_class.call(user)).to eq(
        data: {
          user_id: "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee",
          balance: "50.00"
        }
      )
    end
  end
end
