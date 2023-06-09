require 'cosmic-ruby/domain/reference'
require 'cosmic-ruby/domain/sku'
require 'cosmic-ruby/domain/quantity'
require 'cosmic-ruby/domain/date'
require 'cosmic-ruby/domain/order_id'
require 'cosmic-ruby/domain/batch'
require 'cosmic-ruby/domain/order_line'
require 'cosmic-ruby/infrastructure/batch_repository_sql'
require 'cosmic-ruby/infrastructure/fake_batch_repository'
require 'cosmic-ruby/infrastructure/ORM/batch'
require 'cosmic-ruby/infrastructure/ORM/order_line'
require 'cosmic-ruby/infrastructure/ORM/order_line'
require 'cosmic-ruby/infrastructure/session'

describe BatchRepositorySql do
  let(:session) { Session.new }
  let(:repository) { BatchRepositorySql.new session }

  describe 'add' do
    it 'returns a batch added with its order lines' do
      expected_batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))])

      repository.add(expected_batch)
      session.commit()
      batch = repository.get(Reference.new('REF'))

      expect(batch.reference).to eq expected_batch.reference
      expect(batch.sku).to eq expected_batch.sku
      expect(batch.quantity).to eq expected_batch.quantity
      expect(batch.eta).to eq expected_batch.eta
      expect(batch.lines).to eq [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))]
    end

    it 'returns the batch with the correct reference' do
      expected_batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))])

      repository.add(expected_batch)
      repository.add(Batch.new(Reference.new('REF1'), Sku.new('TABLE1'), Quantity.new(1), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF1'), Sku.new('TABLE1'), Quantity.new(1))]))
      session.commit()
      batch = repository.get(Reference.new('REF'))

      expect(batch.reference).to eq expected_batch.reference
      expect(batch.sku).to eq expected_batch.sku
      expect(batch.quantity).to eq expected_batch.quantity
      expect(batch.eta).to eq expected_batch.eta
      expect(batch.lines).to eq [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))]
    end

  end

  describe 'list' do
    it 'returns all batches' do
      repository.add(Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))]))
      repository.add(Batch.new(Reference.new('REF1'), Sku.new('TABLE1'), Quantity.new(1), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF1'), Sku.new('TABLE1'), Quantity.new(1))]))
      repository.add(Batch.new(Reference.new('REF2'), Sku.new('TABLE1'), Quantity.new(1), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF1'), Sku.new('TABLE1'), Quantity.new(1))]))
      session.commit()
      batches = repository.list
      expect(batches[0].reference).to eq Reference.new('REF')
      expect(batches[1].reference).to eq Reference.new('REF1')
      expect(batches[2].reference).to eq Reference.new('REF2')
    end
  end

  describe 'of' do
    it 'returns a batch added with its order lines' do
      expected_batch = Batch.new(Reference.new('REF'), Sku.new('SEAT'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))])

      repository.add(expected_batch)
      session.commit()
      batch = repository.of(Sku.new('SEAT')).first

      expect(batch.reference).to eq expected_batch.reference
      expect(batch.sku).to eq expected_batch.sku
      expect(batch.quantity).to eq expected_batch.quantity
      expect(batch.eta).to eq expected_batch.eta
      expect(batch.lines).to eq [OrderLine.new(OrderId.new('REF'), Sku.new('TABLE'), Quantity.new(12))]
    end

    it 'returns the batch with the correct reference' do
      expected_batch = Batch.new(Reference.new('REF'), Sku.new('BED'), Quantity.new(12), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF'), Sku.new('BED'), Quantity.new(12))])

      repository.add(expected_batch)
      repository.add(Batch.new(Reference.new('REF1'), Sku.new('LAMP'), Quantity.new(1), Custom::Date.new(1, 1, 2023), [OrderLine.new(OrderId.new('REF1'), Sku.new('TABLE1'), Quantity.new(1))]))
      session.commit()
      batch = repository.of(Sku.new('BED')).first

      expect(batch.reference).to eq expected_batch.reference
      expect(batch.sku).to eq expected_batch.sku
      expect(batch.quantity).to eq expected_batch.quantity
      expect(batch.eta).to eq expected_batch.eta
      expect(batch.lines).to eq [OrderLine.new(OrderId.new('REF'), Sku.new('BED'), Quantity.new(12))]
    end

    it 'returns all batch with the correct sku' do
      batch1 = Batch.new(Reference.new('REF1'), Sku.new('BED'), Quantity.new(12), Custom::Date.new(1, 1, 2023))
      batch2 = Batch.new(Reference.new('REF2'), Sku.new('BED'), Quantity.new(12), Custom::Date.new(1, 1, 2024))
      batch3 = Batch.new(Reference.new('REF3'), Sku.new('LAMP'), Quantity.new(12), Custom::Date.new(1, 1, 2024))

      repository.add(batch1)
      repository.add(batch2)
      repository.add(batch3)
      session.commit()
      batches = repository.of(Sku.new('BED')).map(&:reference)
      expect(batches).to eq [Reference.new('REF1'), Reference.new('REF2')]
    end
  end
end