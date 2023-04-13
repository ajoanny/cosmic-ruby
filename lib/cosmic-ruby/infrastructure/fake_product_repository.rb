require 'cosmic-ruby/domain/product_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class FakeProductRepository < ProductRepository


  def initialize set = Set[], session = FakeSession.new
    @set = set
    @session = session
  end

  def get sku
    product = @set.find { |product| product.sku == sku }
    @session.add product
    product
  end

end