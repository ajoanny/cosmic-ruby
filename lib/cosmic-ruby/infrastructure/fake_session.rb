class FakeSession
  def initialize
    @commit = false
  end

  def add orm_class, method, object
  end

  def commit
    @commit = true
  end
end