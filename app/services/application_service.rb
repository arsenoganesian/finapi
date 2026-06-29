class ApplicationService
  def self.call(...)
    new(...).call
  end

  def call
    raise NotImplementedError, "Subclasses must implement the `call` method"
  end
end
