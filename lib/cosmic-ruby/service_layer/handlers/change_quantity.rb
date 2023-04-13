require 'cosmic-ruby/service_layer/handlers/handler'

class ChangeQuantity < Handler


  def perform event
    @uow.persists do
      batch = @uow.batches.get event.reference
      batch.change_quantity event.quantity
      @uow.commit()
    end
  end
end