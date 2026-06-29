require "rails_helper"

RSpec.describe Transfers::ApplyService do
  describe ".call" do
    let(:sender) { create(:user, balance: 100) }
    let(:recipient) { create(:user, balance: 10) }
    let(:max_amount) { Money::MAX_AMOUNT }

    it "applies transfer between users" do
      result = described_class.call(from_user: sender, to_user: recipient, amount: BigDecimal("40.00"))

      expect(result[:from_user].id).to eq(sender.id)
      expect(result[:to_user].id).to eq(recipient.id)
      expect(sender.reload.balance).to eq(BigDecimal("60"))
      expect(recipient.reload.balance).to eq(BigDecimal("50"))
    end

    it "raises when sender has insufficient funds" do
      expect do
        described_class.call(from_user: sender, to_user: recipient, amount: BigDecimal("1000"))
      end.to raise_error(ServiceError, "Insufficient funds for transfer")

      expect(sender.reload.balance).to eq(BigDecimal("100"))
      expect(recipient.reload.balance).to eq(BigDecimal("10"))
    end

    it "raises when recipient balance exceeds max allowed value" do
      rich_recipient = create(:user, balance: max_amount)

      expect do
        described_class.call(from_user: sender, to_user: rich_recipient, amount: BigDecimal("0.01"))
      end.to raise_error(ServiceError, "Recipient balance exceeds maximum allowed value")
    end
  end
end
