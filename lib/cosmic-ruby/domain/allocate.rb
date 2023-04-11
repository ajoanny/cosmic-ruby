def allocate_in_batches order_line, batches
  batch = batches
    .select { |batch| batch.allocable? order_line}
    .sort
    .first

  if(batch)
    batch.allocate order_line
    batch.reference
  else
    raise OutOfStock.new
  end
end