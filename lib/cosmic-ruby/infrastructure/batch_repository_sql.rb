require 'cosmic-ruby/domain/batch_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'

class BatchRepositorySql < BatchRepository

  def get(reference)
    batch = ORM::Batch.find_by!(reference: reference.reference)
    batch.lines = ORM::OrderLine.where(batch_id: batch.id)
    ORM::Batch.to_model batch
  end

  def add(batch)
    batch_bdd = ORM::Batch.from(batch)
    batch_bdd.save
    batch.lines.each { |line| ORM::OrderLine.from(line, batch_bdd.id).save }
  end

  def list
    ORM::Batch.all.map do |batch|
      batch.lines = ORM::OrderLine.where(batch_id: batch.id)
      ORM::Batch.to_model batch
    end
  end
end