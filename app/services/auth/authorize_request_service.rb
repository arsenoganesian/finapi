module Auth
  class AuthorizeRequestService < ApplicationService
    def initialize(authorization_header:)
      @authorization_header = authorization_header
    end

    def call
      payload = decode_token
      find_user(payload)
    rescue ActiveRecord::RecordNotFound
      raise ServiceError.new("Invalid token subject", status: :unauthorized)
    end

    private

    attr_reader :authorization_header

    def decode_token
      JwtCodec.decode(extract_token)
    end

    def extract_token
      token = authorization_header.to_s.split.last
      raise ServiceError.new("Missing token", status: :unauthorized) if token.blank?

      token
    end

    def find_user(payload)
      User.find(payload[:user_id])
    end
  end
end
