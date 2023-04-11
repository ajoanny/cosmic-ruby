require 'cosmic-ruby/domain/product_repository'
require 'cosmic-ruby/infrastructure/ORM/product'
require 'cosmic-ruby/infrastructure/ORM/batch'

class ProductRepositorySql < ProductRepository

  def initialize session
    @session = session
  end

  def get(sku)
    orm = ORM::Product.find_by(sku: sku.sku)
    unless orm
      batches = ORM::Batch.where(sku: sku.sku)
      orm = ORM::Product.new sku: sku.sku, batches: batches, version: 0
    end
    product = ORM::Product.to_model orm
    @session.add orm, product
    product
  end
end