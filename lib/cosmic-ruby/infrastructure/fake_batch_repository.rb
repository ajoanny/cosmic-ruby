require 'cosmic-ruby/domain/batch_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class FakeBatchRepository < BatchRepository

  def initialize set = Set[], session = FakeSession.new
    @set = set
    @session = session
  end

  def get(reference)
    @set.find { |batch| batch.reference == reference }
  end

  def of(sku)
    @set.select { |batch| batch.sku == sku }
  end

  def add(batch)
    @set.add batch
  end

  def list
    @set.to_a
  end
end