class OrderLine
  attr :order_id, :quantity, :sku
  attr_reader :order_id, :quantity, :sku
  alias_method :eql?, :==
  attr_accessor :id

  def initialize order_id, sku, quantity
    @order_id = order_id
    @sku = sku
    @quantity = quantity
  end

  def == other
    other.class == self.class &&
      other.order_id == @order_id &&
      other.sku == @sku &&
      other.quantity == @quantity
  end

  def hash
    [self.class, order_id, quantity, sku].hash
  end
end