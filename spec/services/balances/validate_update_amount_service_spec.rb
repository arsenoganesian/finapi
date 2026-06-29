require "rails_helper"

RSpec.describe Balances::ValidateUpdateAmountService do
  describe ".call" do
    let(:max_amount) { Money::MAX_AMOUNT }

    it "returns valid positive amount" do
      result = described_class.call(amount: BigDecimal("5.50"))

      expect(result).to eq(BigDecimal("5.50"))
    end

    it "returns valid negative amount" do
      result = described_class.call(amount: BigDecimal("-4.25"))

      expect(result).to eq(BigDecimal("-4.25"))
    end

    it "raises for zero amount" do
      expect do
        described_class.call(amount: BigDecimal("0"))
      end.to raise_error(ServiceError, "Amount must not be zero")
    end

    it "raises when positive amount exceeds maximum allowed value" do
      expect do
        described_class.call(amount: max_amount + BigDecimal("0.01"))
      end.to raise_error(ServiceError, "Amount exceeds maximum allowed value")
    end
  end
end
