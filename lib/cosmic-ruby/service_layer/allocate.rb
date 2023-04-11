def allocate order_line, batch_repository, session
  batchs = batch_repository.list
  if batchs.map(&:sku).none? { |sku| sku == order_line.sku }
    raise SkuUnknown.new order_line.sku
  end
  reference = allocate_in_batches order_line, batchs
  session.commit
  reference
end