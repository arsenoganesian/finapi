class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |error|
    render_error(error.message, :not_found)
  end

  rescue_from ActionController::ParameterMissing do |error|
    render_error(error.message, :unprocessable_content)
  end

  rescue_from JwtCodec::DecodeError do |error|
    render_error(error.message, :unauthorized)
  end

  rescue_from ServiceError do |error|
    render_error(error.message, error.status)
  end

  private

  def render_error(message, status)
    render json: ErrorSerializer.call(message), status: status
  end
end
