require "rails_helper"

RSpec.describe Transfers::ValidateRulesService do
  describe ".call" do
    let(:sender) { create(:user) }
    let(:recipient) { create(:user) }

    it "passes when users are different" do
      expect do
        described_class.call(from_user: sender, to_user: recipient)
      end.not_to raise_error
    end

    it "raises when users are the same" do
      expect do
        described_class.call(from_user: sender, to_user: sender)
      end.to raise_error(ServiceError, "Recipient and sender must be different")
    end
  end
end
