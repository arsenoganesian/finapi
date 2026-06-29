require "rails_helper"

RSpec.describe Transfers::CreateService do
  describe ".call" do
    let(:sender) { create(:user, balance: 100) }
    let(:recipient) { create(:user, balance: 10) }
    let(:max_amount) { Money::MAX_AMOUNT }

    it "transfers funds between users" do
      result = described_class.call(
        from_user_id: sender.id,
        recipient_email: recipient.email,
        amount: "40.00"
      )

      expect(result[:from_user].id).to eq(sender.id)
      expect(result[:to_user].id).to eq(recipient.id)
      expect(sender.reload.balance).to eq(BigDecimal("60"))
      expect(recipient.reload.balance).to eq(BigDecimal("50"))
    end

    it "raises for same sender and recipient" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: sender.email, amount: "1")
      end.to raise_error(ServiceError, "Recipient and sender must be different")
    end

    it "raises for invalid amount" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: recipient.email, amount: "abc")
      end.to raise_error(ServiceError, "Amount is invalid")
    end

    it "raises for invalid amount format" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: recipient.email, amount: "1,01")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end

    it "raises for amount with more than two decimal places" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: recipient.email, amount: "0.009")
      end.to raise_error(ServiceError, "Amount format is invalid")
    end

    it "raises for non-positive amount" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: recipient.email, amount: "0")
      end.to raise_error(ServiceError, "Amount must be greater than 0")
    end

    it "raises when sender has insufficient funds" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: recipient.email, amount: "1000")
      end.to raise_error(ServiceError, "Insufficient funds for transfer")

      expect(sender.reload.balance).to eq(BigDecimal("100"))
      expect(recipient.reload.balance).to eq(BigDecimal("10"))
    end

    it "raises when recipient is not found" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: "missing@example.com", amount: "1.00")
      end.to raise_error(ActiveRecord::RecordNotFound, "Recipient not found")
    end

    it "raises when amount exceeds the maximum allowed value" do
      expect do
        described_class.call(
          from_user_id: sender.id,
          recipient_email: recipient.email,
          amount: (max_amount + BigDecimal("0.01")).to_s("F")
        )
      end.to raise_error(ServiceError, "Amount exceeds maximum allowed value")
    end

    it "raises when recipient balance would exceed the maximum allowed value" do
      rich_recipient = create(:user, balance: max_amount)

      expect do
        described_class.call(from_user_id: sender.id, recipient_email: rich_recipient.email, amount: "0.01")
      end.to raise_error(ServiceError, "Recipient balance exceeds maximum allowed value")
    end
  end
end
