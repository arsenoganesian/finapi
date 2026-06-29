require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module Finapi
  class Application < Rails::Application
    config.load_defaults 8.1

    config.x.jwt_secret =
      ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }

    config.x.jwt_expiration_seconds = Integer(
      ENV.fetch("JWT_EXPIRATION_SECONDS", "3600"),
      exception: false
    )

    config.api_only = true
  end
end
