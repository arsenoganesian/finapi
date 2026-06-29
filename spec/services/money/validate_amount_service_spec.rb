require "rails_helper"

RSpec.describe Money::ValidateAmountService do
  describe ".call" do
    let(:max_amount) { Money::MAX_AMOUNT }

    it "returns valid amount" do
      amount = described_class.call(amount: BigDecimal("40.00"))

      expect(amount).to eq(BigDecimal("40.00"))
    end

    it "raises for non-positive amount" do
      expect do
        described_class.call(amount: BigDecimal("0"))
      end.to raise_error(ServiceError, "Amount must be greater than 0")
    end

    it "raises when amount exceeds max allowed value" do
      expect do
        described_class.call(amount: max_amount + BigDecimal("0.01"))
      end.to raise_error(ServiceError, "Amount exceeds maximum allowed value")
    end
  end
end
