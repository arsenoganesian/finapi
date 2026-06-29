module Auth
  class IssueTokenService < ApplicationService
    def initialize(email:)
      @raw_email = email
    end

    def call
      issue_token(find_user)
    end

    private

    attr_reader :raw_email

    def find_user
      user = User.find_by(email: normalized_email)
      raise ActiveRecord::RecordNotFound, "User not found" unless user

      user
    end

    def issue_token(user)
      JwtCodec.encode(user_id: user.id)
    end

    def normalized_email
      raw_email.to_s.strip.downcase
    end
  end
end
