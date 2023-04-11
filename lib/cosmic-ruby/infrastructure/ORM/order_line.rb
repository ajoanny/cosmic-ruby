require 'active_record'


module ORM
  ModelOrderLine = OrderLine
  class OrderLine < ActiveRecord::Base
    belongs_to :batch
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
  end
end