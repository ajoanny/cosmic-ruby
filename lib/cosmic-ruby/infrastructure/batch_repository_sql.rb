require 'cosmic-ruby/domain/batch_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class BatchRepositorySql < BatchRepository

  def initialize session
    @session = session
  end

  def get(reference)
    batch = ORM::Batch.find_by!(reference: reference.reference)
    batch.lines = ORM::OrderLine.where(batch_id: batch.id)
    model = ORM::Batch.to_model batch
    @session.add ORM::Batch, :save, model
    model
  end

  def add(batch)
    @session.add ORM::Batch, :save, batch
  end

  def list
    ORM::Batch.all.map do |batch|
      batch.lines = ORM::OrderLine.where(batch_id: batch.id)
      ORM::Batch.to_model batch
    end
  end
end