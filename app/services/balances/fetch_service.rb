module Balances
  class FetchService < ApplicationService
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      User.find(user_id)
    end

    private

    attr_reader :user_id
  end
end
