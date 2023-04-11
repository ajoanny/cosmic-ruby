def reallocate order_line, reference, uow
  uow.persists do
    current_batch = uow.batches.get reference
    current_batch.deallocate order_line
    batches = uow.batches.of(order_line.sku)
    if batches.empty?
      raise SkuUnknown.new order_line.sku
    end
    allocate_in_batches order_line, batches
    uow.commit
  end
end