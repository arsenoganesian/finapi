module Balances
  class ApplyUpdateService < ApplicationService
    def initialize(user:, amount:)
      @user = user
      @amount = amount
    end

    def call
      user.with_lock do
        next_balance = user.balance + amount
        raise ServiceError.new("Insufficient funds") if next_balance.negative?
        raise ServiceError.new("Balance exceeds maximum allowed value") if next_balance > Money::MAX_AMOUNT

        user.update!(balance: next_balance)
      end

      user
    end

    private

    attr_reader :user, :amount
  end
end
