require 'cosmic-ruby/domain/events'
require 'cosmic-ruby/service_layer/handlers/send_out_of_sotck_notification'
require 'cosmic-ruby/service_layer/handlers/allocate_handler'
require 'cosmic-ruby/service_layer/handlers/change_quantity'

class MessageBus
  HANDLERS = {
    OutOfStockEvent => [SendOutOfStockNotification],
    AllocationRequired => [AllocateHandler],
    BatchQuantityChanged => [ChangeQuantity]
  }

  def self.handle event, uow
    queue = [event]
    results = []
    while queue.any?
      current_event = queue.pop
      handlers(current_event).each do |handler|
        results << handler.new(uow).perform(current_event)
        queue << uow.events
        queue.flatten!
      end
    end
    return results
  end

  def self.handlers event
    HANDLERS[event.class] || []
  end
end