require 'cosmic-ruby/service_layer/message_bus'
require 'cosmic-ruby/domain/reference'
require 'cosmic-ruby/domain/sku'
require 'cosmic-ruby/domain/quantity'
require 'cosmic-ruby/domain/date'
require 'cosmic-ruby/domain/order_id'
require 'cosmic-ruby/domain/batch'
require 'cosmic-ruby/domain/order_line'
require 'cosmic-ruby/infrastructure/fake_batch_repository'
require 'cosmic-ruby/infrastructure/fake_product_repository'
require 'cosmic-ruby/infrastructure/fake_session'
require 'cosmic-ruby/service_layer/allocate'
require 'cosmic-ruby/service_layer/deallocate'
require 'cosmic-ruby/service_layer/reallocate'
require 'cosmic-ruby/service_layer/change_quantity'
require 'cosmic-ruby/domain/errors/sku_unknown'
require 'cosmic-ruby/infrastructure/fake_unit_of_work'

class MessageBus
  @@events = []

  def self.handle event
    @@events << event
    handlers(event).each { |method| method.call(event) }
  end

  def self.events
    @@events
  end
end

describe 'Service Allocate' do
  fdescribe 'allocate' do
    context 'when the sku is known' do
      it 'returns a batch added with its order lines' do
        batch = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023))
        product = Product.new(Sku.new('TABLE'), [batch])
        repository = FakeProductRepository.new Set[product]
        uow = FakeUnitOfWork.new nil, repository
        reference = allocate(OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12)), uow)

        expect(reference).to eq Reference.new('REF1')
        expect(uow).to be_committed
      end
    end

    context 'when the sku is unknown' do
      it 'returns a batch added with its order lines' do
        batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023))
        product = Product.new(Sku.new('TABLE'), [batch])
        repository = FakeProductRepository.new Set[product]
        uow = FakeUnitOfWork.new nil, repository
        expect {
         allocate(OrderLine.new(OrderId.new('REF'), Sku.new('LAMP'), Quantity.new(12)), uow)
        }.to raise_error SkuUnknown.new(Sku.new('LAMP'))
        expect(uow).not_to be_committed
        expect(uow).to be_rollbacked
      end
    end

    context 'when the is not available item' do
      it 'produce an OutOfStockEvent' do
        batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(1), Custom::Date.new(1, 1, 2023))
        product = Product.new(Sku.new('TABLE'), [batch])
        repository = FakeProductRepository.new Set[product]
        uow = FakeUnitOfWork.new nil, repository
        allocate(OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12)), uow)

        expect(MessageBus.events[-1]).to be_an_instance_of OutOfStockEvent
      end
    end
  end

  describe 'reallocate' do
    context 'when the sku is known' do
      it 'removes the order line ' do
        old_batch = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))])
        new_batch = Batch.new(Reference.new('REF2'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2022), [])
        repository = FakeBatchRepository.new Set[old_batch, new_batch]
        uow = FakeUnitOfWork.new repository
        reallocate(OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12)), Reference.new('REF1'), uow)

        expect(old_batch.lines).to be_empty
        expect(new_batch.lines).to eq [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))]
      end
    end
  end

  describe 'change quantity' do
    context 'where there is enough quantity' do
      it 'change the quantity' do
        batch = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(1))])
        repository = FakeBatchRepository.new Set[batch]
        uow = FakeUnitOfWork.new repository
        change_quantity(Reference.new('REF1'),Quantity.new(10), uow)

        expect(batch.quantity).to eq Quantity.new(10)
        expect(batch.lines).to eq [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(1))]
      end
    end

    context 'where there is not enough quantity' do
      it 'change the quantity and remove order line until the quantity is over 0' do
        batch = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(10), Custom::Date.new(1, 1, 2023),
                          [
                            OrderLine.new(OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1)),
                            OrderLine.new(OrderId.new('1'), Sku.new('TABLE'), Quantity.new(3)),
                            OrderLine.new(OrderId.new('2'), Sku.new('TABLE'), Quantity.new(2))])
        repository = FakeBatchRepository.new Set[batch]
        uow = FakeUnitOfWork.new repository
        change_quantity(Reference.new('REF1'),Quantity.new(2), uow)

        expect(batch.quantity).to eq Quantity.new(2)
        expect(batch.lines).to eq [OrderLine.new(OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1))]
      end
    end
  end
end