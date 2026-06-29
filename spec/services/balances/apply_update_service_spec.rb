require "rails_helper"

RSpec.describe Balances::ApplyUpdateService do
  describe ".call" do
    let(:user) { create(:user, balance: 20) }
    let(:max_amount) { Money::MAX_AMOUNT }

    it "applies positive balance update" do
      result = described_class.call(user:, amount: BigDecimal("5.50"))

      expect(result.id).to eq(user.id)
      expect(user.reload.balance).to eq(BigDecimal("25.5"))
    end

    it "applies negative balance update" do
      described_class.call(user:, amount: BigDecimal("-4.25"))

      expect(user.reload.balance).to eq(BigDecimal("15.75"))
    end

    it "raises when resulting balance exceeds maximum allowed value" do
      rich_user = create(:user, balance: max_amount)

      expect do
        described_class.call(user: rich_user, amount: BigDecimal("0.01"))
      end.to raise_error(ServiceError, "Balance exceeds maximum allowed value")
    end

    it "raises when funds are insufficient" do
      expect do
        described_class.call(user:, amount: BigDecimal("-100"))
      end.to raise_error(ServiceError, "Insufficient funds")

      expect(user.reload.balance).to eq(BigDecimal("20"))
    end
  end
end
