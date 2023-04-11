require 'cosmic-ruby/domain/batch_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class BatchRepositorySql < BatchRepository

  def initialize session
    @session = session
  end

  def get(reference)
    batch = ORM::Batch.find_by!(reference: reference.reference)
    to_model(batch)
  end

  def of(sku)
    batches = ORM::Batch.where(sku: sku.sku)
    batches.map(&method(:to_model))
  end

  def add(batch)
    @session.add ORM::Batch.new, batch
  end

  def list
    ORM::Batch.all.map do |batch|
      to_model(batch)
    end
  end

  private

  def to_model(batch)
    batch.lines = ORM::OrderLine.where(batch_id: batch.id)
    model = ORM::Batch.to_model batch
    @session.add batch, model
    model
  end
end