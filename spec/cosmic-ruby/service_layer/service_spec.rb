require 'cosmic-ruby/domain/reference'
require 'cosmic-ruby/domain/sku'
require 'cosmic-ruby/domain/quantity'
require 'cosmic-ruby/domain/date'
require 'cosmic-ruby/domain/order_id'
require 'cosmic-ruby/domain/batch'
require 'cosmic-ruby/domain/order_line'
require 'cosmic-ruby/infrastructure/fake_batch_repository'
require 'cosmic-ruby/infrastructure/fake_session'
require 'cosmic-ruby/service_layer/allocate'
require 'cosmic-ruby/domain/errors/sku_unknown'

describe 'Service Allocate' do
  describe 'allocate' do
    context 'when the sku is known' do
      it 'returns a batch added with its order lines' do
        batch = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023))
        repository = FakeBatchRepository.new Set[batch]
        session = FakeSession.new
        reference = allocate(OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12)), repository, session)

        expect(reference).to eq Reference.new('REF1')
        expect(session.commit).to be_truthy
      end
    end

    context 'when the sku is unknown' do
      it 'returns a batch added with its order lines' do
        batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023))
        repository = FakeBatchRepository.new Set[batch]
        session = FakeSession.new
        expect {
         allocate(OrderLine.new(OrderId.new('REF'), Sku.new('LAMP'), Quantity.new(12)), repository, session)
        }.to raise_error SkuUnknown.new(Sku.new('LAMP'))
      end
    end
  end
end