require 'cosmic-ruby/domain/batch_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class FakeBatchRepository < BatchRepository

  def initialize set = Set[], session = FakeSession.new
    @set = set
    @session = session
  end

  def get(reference)
    batch = @set.find { |batch| batch.reference == reference }
    @session.add batch
    batch
  end

  def of(sku)
    batches = @set.select { |batch| batch.sku == sku }
    batches.each { |batch| @session.add batch }
    batches
  end

  def add(batch)
    @set.add batch
  end

  def list

    @set.to_a.each { |batch| @session.add batch}
    @set.to_a
  end
end