def deallocate order_line, reference, batch_repository, session
  batch = batch_repository.get reference
  batch.deallocate order_line
  session.commit
end