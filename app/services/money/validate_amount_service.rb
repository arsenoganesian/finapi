module Money
  class ValidateAmountService < ApplicationService
    def initialize(amount:)
      @amount = amount
    end

    def call
      raise ServiceError.new("Amount must be greater than 0") if amount <= 0
      raise ServiceError.new("Amount exceeds maximum allowed value") if amount.abs > Money::MAX_AMOUNT

      amount
    end

    private

    attr_reader :amount
  end
end
