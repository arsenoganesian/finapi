class TransfersController < AuthorizedController
  def create
    Transfers::CreateService.call(
      from_user_id: current_user.id,
      recipient_email: transfer_params[:recipient_email],
      amount: transfer_params[:amount]
    )

    render json: BalanceSerializer.call(current_user.reload), status: :ok
  end

  private

  def transfer_params
    params.require(:transfer).permit(:recipient_email, :amount)
  end
end
