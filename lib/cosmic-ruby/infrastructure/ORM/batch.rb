require 'active_record'
require 'cosmic-ruby/infrastructure/ORM/eta'

module ORM
  BatchModel = Batch
  class Batch < ActiveRecord::Base
    attr_accessor :lines
    has_many :order_lines

    def new_record?
      id.nil?
    end
    def self.from model
      ORM::Batch.new(
        id: model.id,
        reference: model.reference.reference,
        sku: model.sku.sku,
        quantity: model.quantity.value,
        eta: model.eta,
        order_lines: model.lines.map { |line| ORM::OrderLine.from line, model.id })
    end

    def self.to_model orm_model
      batch = BatchModel.new(
        Reference.new(orm_model.reference),
        Sku.new(orm_model.sku),
        Quantity.new(orm_model.quantity),
        Eta.to_date(orm_model.eta),
        orm_model.order_lines.map { |line| ORM::OrderLine.to_model line })

      batch.id = orm_model.id
      batch
    end
  end
end