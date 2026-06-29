class ApplicationSerializer
  def self.call(...)
    new(...).as_json
  end

  def initialize(object)
    @object = object
  end

  def as_json
    raise NotImplementedError, "Subclasses must implement the `as_json` method"
  end

  private

  attr_reader :object

  def data(payload)
    { data: payload }
  end

  def money(value)
    format("%.2f", value)
  end
end
