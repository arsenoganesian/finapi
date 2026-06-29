require "rails_helper"

RSpec.describe Balances::FetchService do
  describe ".call" do
    it "returns user by id" do
      user = create(:user)

      result = described_class.call(user_id: user.id)

      expect(result.id).to eq(user.id)
    end

    it "raises when user is not found" do
      expect do
        described_class.call(user_id: -1)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
