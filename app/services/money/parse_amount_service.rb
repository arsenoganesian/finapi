module Money
  class ParseAmountService < ApplicationService
    AMOUNT_PATTERN = /\A[+-]?\d+(?:\.\d+)?\z/
    AMOUNT_INVALID_MESSAGE = "Amount is invalid"
    AMOUNT_FORMAT_INVALID_MESSAGE = "Amount format is invalid"

    def initialize(raw_amount:)
      @raw_amount = raw_amount
    end

    def call
      value = normalized_amount
      validate_amount_format!(value)

      build_amount(value)
    rescue ArgumentError
      raise ServiceError.new(AMOUNT_INVALID_MESSAGE)
    end

    private

    attr_reader :raw_amount

    def normalized_amount
      raw_amount.to_s.strip
    end

    def validate_amount_format!(value)
      raise ServiceError.new(AMOUNT_FORMAT_INVALID_MESSAGE) if value.include?(",")
      raise ServiceError.new(AMOUNT_INVALID_MESSAGE) unless AMOUNT_PATTERN.match?(value)
      raise ServiceError.new(AMOUNT_FORMAT_INVALID_MESSAGE) if fractional_digits(value).length > 2
    end

    def build_amount(value)
      BigDecimal(value)
    end

    def fractional_digits(value)
      value.delete_prefix("+").delete_prefix("-").split(".", 2).fetch(1, "")
    end
  end
end
