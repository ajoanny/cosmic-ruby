class Event

end

class OutOfStockEvent < Event

end


class AllocationRequired < Event
  attr_accessor :order_line

  def initialize order_line
    @order_line = order_line
  end
end

class BatchQuantityChanged < Event
  attr_accessor :reference, :quantity

  def initialize reference, quantity
    @reference = reference
    @quantity = quantity
  end
end

