class ErrorSerializer < ApplicationSerializer
  alias message object

  def as_json
    { error: message }
  end
end
