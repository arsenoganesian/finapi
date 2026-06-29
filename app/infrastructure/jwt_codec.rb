class JwtCodec
  class DecodeError < StandardError; end

  ALGORITHM = "HS256".freeze

  class << self
    def encode(payload)
      token_payload = payload.to_h.symbolize_keys
      token_payload[:exp] ||= Time.current.to_i + Rails.application.config.x.jwt_expiration_seconds

      JWT.encode(token_payload, Rails.application.config.x.jwt_secret, ALGORITHM)
    end

    def decode(token)
      body, = JWT.decode(
        token,
        Rails.application.config.x.jwt_secret,
        true,
        algorithm: ALGORITHM
      )
      body.with_indifferent_access
    rescue JWT::DecodeError => error
      raise DecodeError, error.message
    end
  end
end
