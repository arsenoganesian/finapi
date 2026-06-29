require "rails_helper"

RSpec.describe ErrorSerializer do
  describe ".call" do
    it "serializes error payload" do
      expect(described_class.call("Something went wrong")).to eq(
        error: "Something went wrong"
      )
    end
  end
end
