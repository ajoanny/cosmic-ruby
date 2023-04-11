def allocate order_line, uow
  reference = nil
  uow.persists do
    batchs = uow.batches.list
    if batchs.map(&:sku).none? { |sku| sku == order_line.sku }
      raise SkuUnknown.new order_line.sku
    end
    reference = allocate_in_batches order_line, batchs
    uow.commit
  end
  reference
end