def change_quantity  reference, quantity, uow
  uow.persists do
    batch = uow.batches.get reference
    batch.change_quantity quantity
    uow.commit()
  end
end