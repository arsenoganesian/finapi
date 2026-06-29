module Balances
  class ValidateUpdateAmountService < ApplicationService
    def initialize(amount:)
      @amount = amount
    end

    def call
      raise ServiceError.new("Amount must not be zero") if amount.zero?
      raise ServiceError.new("Amount exceeds maximum allowed value") if amount.positive? && amount > Money::MAX_AMOUNT

      amount
    end

    private

    attr_reader :amount
  end
end
