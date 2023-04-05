class OrderId
  attr_accessor :id
  alias_method :eql?, :==

  def initialize id
    @id = id
  end

  def == other
    other.class == OrderId && other.id == @id
  end

  def hash
    [self.class, id].hash
  end
end