class BalancesController < AuthorizedController
  def show
    user = Balances::FetchService.call(user_id: current_user.id)

    render json: BalanceSerializer.call(user), status: :ok
  end

  def update
    user = Balances::UpdateService.call(
      user_id: current_user.id,
      amount: params.require(:amount)
    )

    render json: BalanceSerializer.call(user), status: :ok
  end
end
