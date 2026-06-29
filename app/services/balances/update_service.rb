module Balances
  class UpdateService < ApplicationService
    def initialize(user_id:, amount:)
      @user_id = user_id
      @raw_amount = amount
    end

    def call
      amount = parse_amount
      validate_amount!(amount)
      user = find_user

      apply_update!(user:, amount:)
    end

    private

    attr_reader :user_id, :raw_amount

    def parse_amount
      Money::ParseAmountService.call(raw_amount:)
    end

    def validate_amount!(amount)
      validate_non_zero_amount!(amount)
      validate_amount_limit!(amount)

      amount
    end

    def validate_non_zero_amount!(amount)
      raise ServiceError.new("Amount must not be zero") if amount.zero?
    end

    def validate_amount_limit!(amount)
      return unless amount.positive? && amount > Money::MAX_AMOUNT

      raise ServiceError.new("Amount exceeds maximum allowed value")
    end

    def find_user
      User.find(normalized_user_id)
    end

    def apply_update!(user:, amount:)
      user.with_lock do
        next_balance = user.balance + amount
        validate_next_balance!(next_balance)
        user.update!(balance: next_balance)
      end

      user
    end

    def validate_next_balance!(next_balance)
      raise ServiceError.new("Insufficient funds") if next_balance.negative?
      return unless next_balance > Money::MAX_AMOUNT

      raise ServiceError.new("Balance exceeds maximum allowed value")
    end

    def normalized_user_id
      user_id.to_i
    end
  end
end
