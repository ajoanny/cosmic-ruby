require 'cosmic-ruby/domain/events'

class Product
  attr_reader :sku, :batches, :id, :version, :events
  attr_writer :version
  def initialize sku, batches = [], id=nil, version=0
    @sku = sku
    @batches = batches
    @id = id
    @version = version
    @events = []
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
      @events << OutOfStockEvent.new
    end
  end
end