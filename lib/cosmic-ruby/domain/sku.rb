class Sku
  attr_accessor :sku
  alias_method :eql?, :==
  
  def initialize sku
    @sku = sku
  end

  def == other
    other.class == Sku && other.sku == @sku
  end
end