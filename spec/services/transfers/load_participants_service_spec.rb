require "rails_helper"

RSpec.describe Transfers::LoadParticipantsService do
  describe ".call" do
    let(:sender) { create(:user) }
    let(:recipient) { create(:user, email: "recipient@example.com") }

    it "loads sender and recipient users" do
      result = described_class.call(from_user_id: sender.id, recipient_email: recipient.email)

      expect(result[:from_user].id).to eq(sender.id)
      expect(result[:to_user].id).to eq(recipient.id)
    end

    it "normalizes lookup inputs" do
      result = described_class.call(
        from_user_id: sender.id.to_s,
        recipient_email: "  #{recipient.email.upcase}  "
      )

      expect(result[:from_user].id).to eq(sender.id)
      expect(result[:to_user].id).to eq(recipient.id)
    end

    it "raises when sender is not found" do
      expect do
        described_class.call(from_user_id: 0, recipient_email: recipient.email)
      end.to raise_error(ActiveRecord::RecordNotFound, "Sender not found")
    end

    it "raises when recipient is not found" do
      expect do
        described_class.call(from_user_id: sender.id, recipient_email: "missing@example.com")
      end.to raise_error(ActiveRecord::RecordNotFound, "Recipient not found")
    end
  end
end
