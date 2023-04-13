require 'cosmic-ruby/service_layer/handlers/handler'

class AllocateHandler < Handler

  def perform event
    order_line = event.order_line
    reference = nil
    @uow.persists do
      product = @uow.products.get order_line.sku
      if product.nil?
        raise SkuUnknown.new order_line.sku
      end
      reference = product.allocate order_line
      @uow.commit
    end
    reference
  end
end