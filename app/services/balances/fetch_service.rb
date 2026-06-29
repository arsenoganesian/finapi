module Balances
  class FetchService < ApplicationService
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      find_user
    end

    private

    attr_reader :user_id

    def find_user
      User.find(normalized_user_id)
    end

    def normalized_user_id
      user_id.to_i
    end
  end
end
