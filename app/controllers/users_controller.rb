class UsersController < ApplicationController
  def create
    user = Users::CreateService.call(email: user_params[:email])

    render json: UserSerializer.call(user), status: :created
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
