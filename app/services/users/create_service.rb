module Users
  class CreateService < ApplicationService
    EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

    def initialize(email:)
      @raw_email = email
    end

    def call
      email = normalized_email
      validate_email!(email)

      User.create!(email: email)
    rescue ActiveRecord::RecordNotUnique
      raise ServiceError.new("Email has already been taken")
    end

    private

    attr_reader :raw_email

    def normalized_email
      raw_email.to_s.strip.downcase
    end

    def validate_email!(email)
      raise ServiceError.new("Email is required") if email.blank?
      raise ServiceError.new("Email format is invalid") unless EMAIL_FORMAT.match?(email)
      raise ServiceError.new("Email has already been taken") if User.exists?(email: email)
    end
  end
end
