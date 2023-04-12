require 'cosmic-ruby/domain/reference'
require 'cosmic-ruby/domain/sku'
require 'cosmic-ruby/domain/quantity'
require 'cosmic-ruby/domain/date'
require 'cosmic-ruby/domain/order_id'
require 'cosmic-ruby/domain/batch'
require 'cosmic-ruby/domain/order_line'
require 'cosmic-ruby/infrastructure/product_repository_sql'
require 'cosmic-ruby/infrastructure/ORM/product'
require 'cosmic-ruby/infrastructure/session'
require 'pry'
describe ProductRepositorySql do
  let(:session) { Session.new }
  let(:repository) { ProductRepositorySql.new session }

  describe 'get' do
    it 'returns a product with all its batches' do
      batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))])
      batch1 = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(10), Custom::Date.new(1, 2, 2023), [])
      batch2 = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(10), Custom::Date.new(1, 3, 2023), [])
      batch3 = Batch.new(Reference.new('REF'), Sku.new('LAMP'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [])
      save [batch, batch1, batch2, batch3]

      product = repository.get(Sku.new('TABLE'))

      expect(product.batches).to eq [batch, batch1, batch2]
      expect(product.version).to eq 0
      end
  end

  describe 'version' do
    it 'returns a product with all its batches' do
      batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(2))])
      product = Product.new(Sku.new('TABLE'), [batch])
      ORM::Product.from(product).save

      product1 = repository.get(Sku.new('TABLE'))
      product2 = repository.get(Sku.new('TABLE'))
      product1.allocate OrderLine.new(OrderId.new('REF3'), Sku.new('TABLE'), Quantity.new(5))
      product2.allocate OrderLine.new(OrderId.new('REF2'), Sku.new('TABLE'), Quantity.new(1))

      expect { session.commit }.to raise_exception
    end
  end
end

def save batches
  batches.each { |batch| ORM::Batch.from(batch).save }
  session.commit
end