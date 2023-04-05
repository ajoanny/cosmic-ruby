class Quantity
  attr_accessor :value
  alias_method :eql?, :==

  def initialize value
    @value = value
  end

  def -(other)
    Quantity.new(@value - other.value)
  end

  def +(other)
    Quantity.new(@value + other.value)
  end

  def < other
    @value < other.value
  end

  def > other
    @value < other.value
  end

  def <= other
    @value <= other.value
  end

  def >= other
    @value >= other.value
  end

  def == other
    other.class == self.class && other.value == @value
  end

  def hash
    [self.class, value].hash
  end
end