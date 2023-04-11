class SkuUnknown < Exception
  attr_accessor :sku
  def initialize(sku = nil)
    super
    @sku = sku
  end

  def ==(other)
    other.class == SkuUnknown && other.sku == self.sku
  end
end