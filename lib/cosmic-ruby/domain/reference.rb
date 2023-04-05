class Reference
  attr_accessor :reference
  alias_method :eql?, :==

  def initialize reference
    @reference = reference
  end

  def == other
    other.class == Reference && other.reference == @reference
  end

  def hash
    [self.class, reference].hash
  end
end