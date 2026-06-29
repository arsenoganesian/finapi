class UserSerializer < ApplicationSerializer
  alias user object

  def as_json
    data(
      user_id: user.external_id,
      email: user.email,
      balance: money(user.balance)
    )
  end
end
