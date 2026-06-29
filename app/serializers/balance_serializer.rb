class BalanceSerializer < ApplicationSerializer
  alias user object

  def as_json
    data(
      user_id: user.external_id,
      balance: money(user.balance)
    )
  end
end
