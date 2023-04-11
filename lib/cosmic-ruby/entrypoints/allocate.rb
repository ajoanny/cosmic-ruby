require 'cosmic-ruby/service_layer/allocate'
require 'cosmic-ruby/service_layer/deallocate'
require 'cosmic-ruby/service_layer/reallocate'
require 'cosmic-ruby/service_layer/change_quantity'

require 'json'
module Allocate
  def self.included app
    app.get "/allocate" do
      content_type :json

      line = OrderLine.new(
        OrderId.new(params[:order_id]),
        Sku.new(params[:sku]),
       Quantity.new(Integer(params[:quantity])))

      begin
        reference = allocate line, dependencies.uow
      rescue SkuUnknown
        [400, { message: "Invalid Sku #{params[:sku]}"}.to_json]
      else
        [201, { reference: reference.reference}.to_json]
      end

    end

    app.post "/deallocate" do
      content_type :json

      line = OrderLine.new(
        OrderId.new(params[:order_id]),
        Sku.new(params[:sku]),
        Quantity.new(Integer(params[:quantity])))

      reference = Reference.new params[:reference]

      deallocate line, reference, dependencies.uow
    end

    app.post "/reallocate" do
      content_type :json

      line = OrderLine.new(
        OrderId.new(params[:order_id]),
        Sku.new(params[:sku]),
        Quantity.new(Integer(params[:quantity])))

      reference = Reference.new params[:reference]

      reallocate line, reference, dependencies.uow
  end

   app.post "/change_quantity" do
      content_type :json

      quantity = Quantity.new(Integer(params[:quantity]))
      reference = Reference.new params[:reference]

      change_quantity reference, quantity, dependencies.uow
    end

  end
end