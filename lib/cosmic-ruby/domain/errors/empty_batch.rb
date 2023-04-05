class EmptyBatch < Exception
  attr_accessor :sku
  def initialize(sku = nil)
    super
    @sku = sku
  end

  def ==(other)
    other.class == EmptyBatch && other.sku == self.sku
  end
end