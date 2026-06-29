require "rails_helper"

RSpec.describe Balances::UpdateService do
  describe ".call" do
    let(:user) { create(:user, balance: 20) }
    let(:max_amount) { Money::MAX_AMOUNT }

    it "credits user balance" do
      result = described_class.call(user_id: user.id, amount: "5.50")

      expect(result.id).to eq(user.id)
      expect(user.reload.balance).to eq(BigDecimal("25.5"))
    end

    it "debits user balance" do
      described_class.call(user_id: user.id, amount: "-4.25")

      expect(user.reload.balance).to eq(BigDecimal("15.75"))
    end

    it "raises for zero amount" do
      expect do
        described_class.call(user_id: user.id, amount: "0")
      end.to raise_error(ServiceError, "Amount must not be zero")
    end

    it "raises for invalid amount" do
      expect do
        described_class.call(user_id: user.id, amount: "abc")
      end.to raise_error(ServiceError, "Amount is invalid")
    end

    it "raises for invalid comma amount format" do
      expect do
        described_class.call(user_id: user.id, amount: "1,01")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end

    it "raises for amount with more than two decimal places" do
      expect do
        described_class.call(user_id: user.id, amount: "0.009")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end

    it "raises for tiny amount with more than two decimal places" do
      expect do
        described_class.call(user_id: user.id, amount: "0.001")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end

    it "raises when amount exceeds the maximum allowed value" do
      expect do
        described_class.call(user_id: user.id, amount: (max_amount + BigDecimal("0.01")).to_s("F"))
      end.to raise_error(ServiceError, "Amount exceeds maximum allowed value")
    end

    it "raises when resulting balance exceeds the maximum allowed value" do
      rich_user = create(:user, balance: max_amount)

      expect do
        described_class.call(user_id: rich_user.id, amount: "0.01")
      end.to raise_error(ServiceError, "Balance exceeds maximum allowed value")
    end

    it "raises when funds are insufficient" do
      expect do
        described_class.call(user_id: user.id, amount: "-100")
      end.to raise_error(ServiceError, "Insufficient funds")

      expect(user.reload.balance).to eq(BigDecimal("20"))
    end
  end
end
