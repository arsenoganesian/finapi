module Users
  class CreateService < ApplicationService
    EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

    def initialize(email:)
      @raw_email = email
    end

    def call
      email = normalized_email
      validate_email!(email)

      create_user(email)
    rescue ActiveRecord::RecordNotUnique
      raise ServiceError.new("Email has already been taken")
    end

    private

    attr_reader :raw_email

    def create_user(email)
      User.create!(email: email)
    end

    def normalized_email
      raw_email.to_s.strip.downcase
    end

    def validate_email!(email)
      validate_email_presence!(email)
      validate_email_format!(email)
      validate_email_uniqueness!(email)
    end

    def validate_email_presence!(email)
      raise ServiceError.new("Email is required") if email.blank?
    end

    def validate_email_format!(email)
      raise ServiceError.new("Email format is invalid") unless EMAIL_FORMAT.match?(email)
    end

    def validate_email_uniqueness!(email)
      raise ServiceError.new("Email has already been taken") if User.exists?(email: email)
    end
  end
end
