module Transfers
  class CreateService < ApplicationService
    def initialize(from_user_id:, recipient_email:, amount:)
      @from_user_id = from_user_id
      @recipient_email = recipient_email
      @raw_amount = amount
    end

    def call
      amount = parse_amount
      validate_amount!(amount)
      from_user = find_sender
      to_user = find_recipient
      validate_distinct_users!(from_user:, to_user:)

      apply_transfer!(from_user:, to_user:, amount:)
    end

    private

    attr_reader :from_user_id, :recipient_email, :raw_amount

    def parse_amount
      Money::ParseAmountService.call(raw_amount:)
    end

    def validate_amount!(amount)
      validate_positive_amount!(amount)
      validate_amount_limit!(amount)

      amount
    end

    def validate_positive_amount!(amount)
      raise ServiceError.new("Amount must be greater than 0") if amount <= 0
    end

    def validate_amount_limit!(amount)
      raise ServiceError.new("Amount exceeds maximum allowed value") if amount.abs > Money::MAX_AMOUNT
    end

    def find_sender
      from_user = User.find_by(id: normalized_from_user_id)
      raise ActiveRecord::RecordNotFound, "Sender not found" unless from_user

      from_user
    end

    def find_recipient
      to_user = User.find_by(email: normalized_recipient_email)
      raise ActiveRecord::RecordNotFound, "Recipient not found" unless to_user

      to_user
    end

    def validate_distinct_users!(from_user:, to_user:)
      raise ServiceError.new("Recipient and sender must be different") if from_user.id == to_user.id
    end

    def apply_transfer!(from_user:, to_user:, amount:)
      User.transaction do
        lock_users!(from_user:, to_user:)
        validate_sender_balance!(from_user:, amount:)
        validate_recipient_capacity!(to_user:, amount:)
        apply_balance_updates!(from_user:, to_user:, amount:)
      end

      { from_user:, to_user: }
    end

    def lock_users!(from_user:, to_user:)
      [ from_user, to_user ].sort_by(&:id).each(&:lock!)
    end

    def validate_sender_balance!(from_user:, amount:)
      raise ServiceError.new("Insufficient funds for transfer") if from_user.balance < amount
    end

    def validate_recipient_capacity!(to_user:, amount:)
      return unless to_user.balance + amount > Money::MAX_AMOUNT

      raise ServiceError.new("Recipient balance exceeds maximum allowed value")
    end

    def apply_balance_updates!(from_user:, to_user:, amount:)
      from_user.update!(balance: from_user.balance - amount)
      to_user.update!(balance: to_user.balance + amount)
    end

    def normalized_from_user_id
      from_user_id.to_i
    end

    def normalized_recipient_email
      recipient_email.to_s.strip.downcase
    end
  end
end
