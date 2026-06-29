module Transfers
  class ApplyService < ApplicationService
    def initialize(from_user:, to_user:, amount:)
      @from_user = from_user
      @to_user = to_user
      @amount = amount
    end

    def call
      User.transaction do
        [ from_user, to_user ].sort_by(&:id).each(&:lock!)

        if from_user.balance < amount
          raise ServiceError.new("Insufficient funds for transfer")
        end

        if to_user.balance + amount > Money::MAX_AMOUNT
          raise ServiceError.new("Recipient balance exceeds maximum allowed value")
        end

        from_user.update!(balance: from_user.balance - amount)
        to_user.update!(balance: to_user.balance + amount)
      end

      { from_user:, to_user: }
    end

    private

    attr_reader :from_user, :to_user, :amount
  end
end
