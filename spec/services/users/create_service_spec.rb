require "rails_helper"

RSpec.describe Users::CreateService do
  describe ".call" do
    it "creates user with normalized email" do
      user = described_class.call(email: "  TEST@Example.COM ")

      expect(user).to be_persisted
      expect(user.email).to eq("test@example.com")
      expect(user.balance).to eq(BigDecimal("0"))
    end

    it "raises for blank email" do
      expect do
        described_class.call(email: " ")
      end.to raise_error(ServiceError, "Email is required")
    end

    it "raises for invalid email format" do
      expect do
        described_class.call(email: "not-email")
      end.to raise_error(ServiceError, "Email format is invalid")
    end

    it "raises for duplicate email after normalization" do
      create(:user, email: "john@example.com")

      expect do
        described_class.call(email: " JOHN@example.com ")
      end.to raise_error(ServiceError, "Email has already been taken")
    end
  end
end
