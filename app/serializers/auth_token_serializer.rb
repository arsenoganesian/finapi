class AuthTokenSerializer < ApplicationSerializer
  alias token object

  def as_json
    data(token: token)
  end
end
