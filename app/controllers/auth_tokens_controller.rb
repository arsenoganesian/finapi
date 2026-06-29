class AuthTokensController < ApplicationController
  def create
    token = Auth::IssueTokenService.call(email: params.require(:email))

    render json: AuthTokenSerializer.call(token), status: :ok
  end
end
