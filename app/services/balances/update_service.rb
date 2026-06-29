module Balances
  class UpdateService < ApplicationService
    def initialize(user_id:, amount:)
      @user_id = user_id
      @raw_amount = amount
    end

    def call
      user = User.find(user_id)
      amount = Money::ParseAmountService.call(raw_amount:)
      amount = Balances::ValidateUpdateAmountService.call(amount:)

      Balances::ApplyUpdateService.call(user:, amount:)
    end

    private

    attr_reader :user_id, :raw_amount
  end
end
