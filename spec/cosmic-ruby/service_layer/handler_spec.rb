require 'cosmic-ruby/service_layer/message_bus'

describe 'Handler' do
  describe 'allocate' do
    it 'returns a batch added with its order lines' do
        batch = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023))
        product = Product.new(Sku.new('TABLE'), [batch])
        ORM::Product.from(product).save
        event = AllocationRequired.new OrderLine.new(OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1))
        session = Session.new
        uoa = UnitOfWorkActiveRecord.new session
        results = MessageBus.handle event, uoa

        expect(results).to eq [Reference.new('REF1')]
    end

    it 'returns a batch added with its order lines' do
      line1 = OrderLine.new OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1)
      line2 = OrderLine.new OrderId.new('2'), Sku.new('TABLE'), Quantity.new(5)
      line3 = OrderLine.new OrderId.new('3'), Sku.new('TABLE'), Quantity.new(5)
      line4 = OrderLine.new OrderId.new('4'), Sku.new('TABLE'), Quantity.new(5)
      batch1 = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(10), Custom::Date.new(1, 1, 2023), [line1, line2, line3, line4])
      batch2 = Batch.new(Reference.new('REF2'), Sku.new('TABLE'), Quantity.new(16), Custom::Date.new(1, 1, 2023))
      product = Product.new(Sku.new('TABLE'), [batch1, batch2])
      ORM::Product.from(product).save
      event = BatchQuantityChanged.new(Reference.new('REF1'), Quantity.new(1))
      session = Session.new
      uoa = UnitOfWorkActiveRecord.new session
      repository = BatchRepositorySql.new session
      MessageBus.handle event, uoa

      expect(repository.get(Reference.new('REF1')).lines).to eq [line1]
      expect(repository.get(Reference.new('REF2')).lines).to eq [line2, line3, line4]
    end

    fit 'returns a batch added with its order lines' do
      line1 = OrderLine.new OrderId.new('1'), Sku.new('TABLE'), Quantity.new(1)
      line2 = OrderLine.new OrderId.new('2'), Sku.new('TABLE'), Quantity.new(5)
      line3 = OrderLine.new OrderId.new('3'), Sku.new('TABLE'), Quantity.new(5)
      line4 = OrderLine.new OrderId.new('4'), Sku.new('TABLE'), Quantity.new(5)
      batch1 = Batch.new(Reference.new('REF1'), Sku.new('TABLE'), Quantity.new(10), Custom::Date.new(1, 1, 2023), [line1, line2, line3, line4])
      batch2 = Batch.new(Reference.new('REF2'), Sku.new('TABLE'), Quantity.new(16), Custom::Date.new(1, 1, 2023))
      product = Product.new(Sku.new('TABLE'), [batch1, batch2])
      ORM::Product.from(product).save
      event = BatchQuantityChanged.new(Reference.new('REF1'), Quantity.new(1))
      session = FakeSession.new
      repositories = {
        batches: FakeBatchRepository.new(Set[batch1, batch2], session),
        products: FakeProductRepository.new(Set[product], session)
      }
      uoa = FakeUnitOfWork.new repositories, session
      MessageBus.handle event, uoa

      expect(batch1.lines).to eq [line1]
      expect(batch2.lines).to eq [line2, line3, line4]
    end
  end
end