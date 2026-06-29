module Transfers
  class CreateService < ApplicationService
    def initialize(from_user_id:, recipient_email:, amount:)
      @from_user_id = from_user_id
      @recipient_email = recipient_email
      @raw_amount = amount
    end

    def call
      amount = Money::ParseAmountService.call(raw_amount:)
      amount = Money::ValidateAmountService.call(amount:)
      participants = Transfers::LoadParticipantsService.call(from_user_id:, recipient_email:)
      from_user = participants[:from_user]
      to_user = participants[:to_user]

      Transfers::ValidateRulesService.call(from_user:, to_user:)
      Transfers::ApplyService.call(from_user:, to_user:, amount:)
    end

    private

    attr_reader :from_user_id, :recipient_email, :raw_amount
  end
end
