require 'cosmic-ruby/domain/events'

SEND_EMAIL = Proc.new { |event|  puts "OutOfStock Email" }

class MessageBus
  HANDLERS = {
    OutOfStockEvent => [SEND_EMAIL]
  }

  def self.handle event
    handlers(event).each { |method| method.call(event) }
  end

  def self.handlers event
    HANDLERS[event.class] || []
  end
end