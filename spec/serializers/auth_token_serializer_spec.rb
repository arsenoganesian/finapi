require "rails_helper"

RSpec.describe AuthTokenSerializer do
  describe ".call" do
    it "serializes token payload" do
      expect(described_class.call("jwt-token")).to eq(
        data: {
          token: "jwt-token"
        }
      )
    end
  end
end
