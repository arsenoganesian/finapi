class AuthorizedController < ApplicationController
  before_action :authorize_request!

  private

  attr_reader :current_user

  def authorize_request!
    @current_user = Auth::AuthorizeRequestService.call(
      authorization_header: request.authorization
    )
  end
end
