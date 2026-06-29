require "rails_helper"

RSpec.describe Money::ParseAmountService do
  describe ".call" do
    it "parses a valid amount" do
      amount = described_class.call(raw_amount: "40.00")

      expect(amount).to eq(BigDecimal("40.00"))
    end

    it "raises for invalid amount" do
      expect do
        described_class.call(raw_amount: "abc")
      end.to raise_error(ServiceError, "Amount is invalid")
    end

    it "raises for invalid format" do
      expect do
        described_class.call(raw_amount: "1,01")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end

    it "raises for more than two decimal places" do
      expect do
        described_class.call(raw_amount: "0.009")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end
  end
end
