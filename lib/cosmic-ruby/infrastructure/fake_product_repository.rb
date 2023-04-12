require 'cosmic-ruby/domain/product_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class FakeProductRepository < ProductRepository

  def initialize set = Set[]
    @set = set
  end

  def get sku
    @set.find { |product| product.sku == sku }
  end

end