require 'active_record'


module ORM
  ModelOrderLine = OrderLine
  class OrderLine < ActiveRecord::Base
    belongs_to :batch
    attr_accessor :model

    def new_record?
      id.nil?
    end

    def self.from model, batch_id
      OrderLine.new id: model.id, order_id: model.order_id.id, sku: model.sku.sku, quantity: model.quantity.value, batch_id: batch_id
    end

    def self.to_model orm_model
      line = ModelOrderLine.new OrderId.new(orm_model.order_id), Sku.new(orm_model.sku), Quantity.new(orm_model.quantity)
      line.id = orm_model.id
      line
    end

    def _save model
      _update(model)
      save!
    end

    def _update(model)
      self.order_id = model.order_id.id
      self.sku = model.sku.sku
      self.quantity = model.quantity.value
      self.batch_id = batch_id
    end
  end
end