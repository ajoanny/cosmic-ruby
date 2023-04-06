require 'active_record'


module ORM
  ModelOrderLine = OrderLine
  class OrderLine < ActiveRecord::Base

    def self.from model, batch_id
      OrderLine.new order_id: model.order_id.id, sku: model.sku.sku, quantity: model.quantity.value, batch_id: batch_id
    end
    def self.to_model orm_model
      ModelOrderLine.new OrderId.new(orm_model.order_id), Sku.new(orm_model.sku), Quantity.new(orm_model.quantity)
    end
  end
end