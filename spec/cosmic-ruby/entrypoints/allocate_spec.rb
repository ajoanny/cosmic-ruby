require 'ostruct'
require 'json'

require 'cosmic-ruby/infrastructure/session'
require 'cosmic-ruby/infrastructure/unit_of_work_active_record'

class AllocateServer < ServerTest
  include Allocate
end

describe 'Route Allocate' do
  let(:app) { AllocateServer }
  let(:session) { Session.new }

  describe 'Route Allocate' do
    before(:each) do
      ORM::Batch.from(Batch.new Reference.new('R1'), Sku.new('TABLE'), Quantity.new(1), nil).save
      ORM::Batch.from(Batch.new Reference.new('R2'), Sku.new('TABLE'), Quantity.new(1), Custom::Date.new(1,1,2023)).save
    end

    it 'returns the batch reference' do
      app.inject OpenStruct.new({ uow: UnitOfWorkActiveRecord.new(session) })

      get "/allocate", order_id: '1', sku: 'TABLE', quantity: 1

      expect(last_response.status).to eq 201
      expect(JSON.parse(last_response.body)['reference']).to eq 'R1'
    end

    it 'returns an error' do
      app.inject OpenStruct.new({ uow: UnitOfWorkActiveRecord.new(session) })

      get "/allocate", order_id: '1', sku: 'LAMP', quantity: 1

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)['message']).to eq 'Invalid Sku LAMP'
    end
  end

  describe 'Route Deallocate' do
    before(:each) do
      batch = ORM::Batch.from(Batch.new Reference.new('R1'), Sku.new('TABLE'), Quantity.new(1), nil)
      batch.save
      ORM::OrderLine.from(OrderLine.new(OrderId.new('O1'), Sku.new('TABLE'), Quantity.new(1)), batch.id).save
    end

    it 'returns 200' do
      app.inject OpenStruct.new({ uow: UnitOfWorkActiveRecord.new(session) })

      post "/deallocate", order_id: '1', sku: 'TABLE', quantity: 1, reference: 'R1'
      expect(last_response.status).to eq 200
    end
  end

  describe 'Route Reallocate' do
    before(:each) do
      batch = ORM::Batch.from(Batch.new Reference.new('R1'), Sku.new('TABLE'), Quantity.new(1), Custom::Date.new(1,1,2023))
      ORM::Batch.from(Batch.new Reference.new('R2'), Sku.new('TABLE'), Quantity.new(1), nil).save
      batch.save
      ORM::OrderLine.from(OrderLine.new(OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1)), batch.id).save
    end

    it 'returns 200' do
      app.inject OpenStruct.new({ uow: UnitOfWorkActiveRecord.new(session) })

      post "/reallocate", order_id: '1', sku: 'TABLE', quantity: 1, reference: 'R1'

      expect(last_response.status).to eq 200
    end
  end

  fdescribe 'Route Change_Quantity' do
    before(:each) do
      batch = ORM::Batch.from(Batch.new Reference.new('R1'), Sku.new('TABLE'), Quantity.new(1), Custom::Date.new(1,1,2023))
      ORM::Batch.from(Batch.new Reference.new('R2'), Sku.new('TABLE'), Quantity.new(1), nil).save
      batch.save
      ORM::OrderLine.from(OrderLine.new(OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1)), batch.id).save
    end

    it 'returns 200' do
      app.inject OpenStruct.new({ uow: UnitOfWorkActiveRecord.new(session) })

      post "/change_quantity", quantity: 1, reference: 'R1'

      expect(last_response.status).to eq 200
    end
  end

end