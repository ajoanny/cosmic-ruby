class Batch
  attr :sku, :quantity, :lines, :eat
  attr_reader :reference, :eta
  def initialize reference, sku, quantity, eta
    @reference = reference
    @sku = sku
    @quantity = quantity
    @lines = []
    @eta = eta
  end

  def allocate order_line
    if(available_quantity < order_line.quantity)
      raise EmptyBatch.new @sku
    end
    if @lines.none? order_line
      @lines << order_line
    end
  end

  def available_quantity
    @quantity - @lines.map(&:quantity).sum(Quantity.new(0))
  end

  def allocable? order_line
    @sku == order_line.sku && available_quantity >= order_line.quantity
  end

  def deallocate order_line
    @lines.delete order_line
  end

  def <=> other
    other.eta <=> self.eta
  end
end