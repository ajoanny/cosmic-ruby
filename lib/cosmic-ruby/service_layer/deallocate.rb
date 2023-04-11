def deallocate order_line, reference, uow
  uow.persists do
    batch = uow.batches.get reference
    batch.deallocate order_line
    uow.commit
  end
end