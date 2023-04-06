require 'active_record'
require 'cosmic-ruby/infrastructure/ORM/eta'

module ORM
  BatchModel = Batch
  class Batch < ActiveRecord::Base
    attr_accessor :lines

    def self.from model
      ORM::Batch.new(reference: model.reference.reference, sku: model.sku.sku, quantity: model.quantity.value, eta: model.eta)
    end

    def self.to_model orm_model
      BatchModel.new(
        Reference.new(orm_model.reference),
        Sku.new(orm_model.sku),
        Quantity.new(orm_model.quantity),
        Eta.to_date(orm_model.eta),
        orm_model.lines.map { |line| ORM::OrderLine.to_model line })
    end
  end
end