class ServiceError < StandardError
  attr_reader :status

  def initialize(message, status: :unprocessable_content)
    @status = status
    super(message)
  end
end
