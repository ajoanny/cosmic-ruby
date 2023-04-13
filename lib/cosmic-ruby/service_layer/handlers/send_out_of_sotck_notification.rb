require 'cosmic-ruby/service_layer/handlers/handler'

class SendOutOfStockNotification < Handler

  def perform event
    puts "OutOfStock Email"
  end
end