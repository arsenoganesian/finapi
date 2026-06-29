module Transfers
  class ValidateRulesService < ApplicationService
    def initialize(from_user:, to_user:)
      @from_user = from_user
      @to_user = to_user
    end

    def call
      raise ServiceError.new("Recipient and sender must be different") if from_user.id == to_user.id
    end

    private

    attr_reader :from_user, :to_user
  end
end
