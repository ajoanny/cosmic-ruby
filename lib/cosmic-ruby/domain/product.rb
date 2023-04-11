class Product
  attr_reader :sku, :batches, :id, :version
  attr_writer :version
  def initialize sku, batches = [], id=nil, version=0
    @sku = sku
    @batches = batches
    @id = id
    @version = version
  end

  def allocate order_line
    batch = @batches
              .select { |batch| batch.allocable? order_line}
              .sort
              .first

    if(batch)
      batch.allocate order_line
      @version += 1
      batch.reference
    else
      raise OutOfStock.new
    end
  end
end