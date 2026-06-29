module Auth
  class AuthorizeRequestService < ApplicationService
    def initialize(authorization_header:)
      @authorization_header = authorization_header
    end

    def call
      token = authorization_header.to_s.split.last
      raise ServiceError.new("Missing token", status: :unauthorized) if token.blank?

      payload = JwtCodec.decode(token)
      User.find(payload[:user_id])
    rescue ActiveRecord::RecordNotFound
      raise ServiceError.new("Invalid token subject", status: :unauthorized)
    end

    private

    attr_reader :authorization_header
  end
end
