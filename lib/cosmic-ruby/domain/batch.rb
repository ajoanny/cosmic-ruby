class Batch
  attr :sku, :quantity, :lines, :eat
  attr_reader :reference, :eta
  attr_accessor :id
  def initialize reference, sku, quantity, eta, lines = []
    @reference = reference
    @sku = sku
    @quantity = quantity
    @lines = lines
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

  def change_quantity quantity
    @quantity = quantity
    while available_quantity < Quantity.new(0)
      lines.pop
    end
  end

  def <=> other
    other.eta <=> self.eta
  end

  def == other
    other.class == self.class && other.reference == self.reference
  end
end