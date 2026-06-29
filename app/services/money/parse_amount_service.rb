module Money
  class ParseAmountService < ApplicationService
    AMOUNT_PATTERN = /\A[+-]?\d+(?:\.\d+)?\z/
    AMOUNT_INVALID_MESSAGE = "Amount is invalid"
    AMOUNT_FORMAT_INVALID_MESSAGE = "Amount format is invalid"

    def initialize(raw_amount:)
      @raw_amount = raw_amount
    end

    def call
      value = raw_amount.to_s.strip
      raise ServiceError.new(AMOUNT_FORMAT_INVALID_MESSAGE) if value.include?(",")
      raise ServiceError.new(AMOUNT_INVALID_MESSAGE) unless AMOUNT_PATTERN.match?(value)
      raise ServiceError.new(AMOUNT_FORMAT_INVALID_MESSAGE) if fractional_digits(value).length > 2

      BigDecimal(value)
    rescue ArgumentError
      raise ServiceError.new(AMOUNT_INVALID_MESSAGE)
    end

    private

    attr_reader :raw_amount

    def fractional_digits(value)
      value.delete_prefix("+").delete_prefix("-").split(".", 2).fetch(1, "")
    end
  end
end
