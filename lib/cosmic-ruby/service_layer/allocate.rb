require 'cosmic-ruby/service_layer/message_bus'

def allocate order_line, uow
  reference = nil
  product = nil
  uow.persists do
    product = uow.products.get order_line.sku
    if product.nil?
      raise SkuUnknown.new order_line.sku
    end
    begin
    end
    reference = product.allocate order_line
    uow.commit
  end
  MessageBus.handle product.events[-1]
  reference
end