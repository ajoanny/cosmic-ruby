require 'cosmic-ruby/domain/batch'
require 'cosmic-ruby/domain/order_line'
require 'cosmic-ruby/domain/order_id'
require 'cosmic-ruby/domain/errors/empty_batch'
require 'cosmic-ruby/domain/quantity'
require 'cosmic-ruby/domain/reference'
require 'cosmic-ruby/domain/sku'
require 'cosmic-ruby/domain/date'

describe Batch do
  describe '#allocate' do
      it 'decrease quantity available in the batch by the quantity of the order line' do
        batch = Batch.new(Reference.new('REF'), Sku.new('SMALL-TABLE'), Quantity.new(20), Custom::Date.new(1, 1, 2023))
        line = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(2))

        batch.allocate(line)

        expect(batch.available_quantity).to eq Quantity.new(18)
      end

     it 'decrease quantity available in the batch by the quantity of all order lines' do
        batch = Batch.new(Reference.new('REF'), Sku.new('SMALL-TABLE'), Quantity.new(20), Custom::Date.new(1, 1, 2023))
        line1 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(2))
        line2 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(3))
        line3 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(1))

        batch.allocate(line1)
        batch.allocate(line2)
        batch.allocate(line3)

        expect(batch.available_quantity).to eq Quantity.new(14)
      end

      it 'decrease quantity until nothing left' do
        batch = Batch.new(Reference.new('REF'), Sku.new('SMALL-TABLE'), Quantity.new(14), Custom::Date.new(1, 1, 2023))
        line1 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(10))
        line2 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(3))
        line3 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(1))

        batch.allocate(line1)
        batch.allocate(line2)
        batch.allocate(line3)

        expect(batch.available_quantity).to eq Quantity.new(0)
      end

      context 'when there is no quantity available in the batch' do
        it 'throws an error EmptyBatch error' do
          error = EmptyBatch.new(Sku.new('SMALL-TABLE'))
          batch = Batch.new(Reference.new('REF'), Sku.new('SMALL-TABLE'), Quantity.new(2), Custom::Date.new(1, 1, 2023))
          line1 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(1))
          line2 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(3))

          batch.allocate(line1)


          expect { batch.allocate(line2) }.to raise_error(error)
        end
      end

      it 'does not allocate the line two times' do
        batch = Batch.new(Reference.new('REF'), Sku.new('SMALL-TABLE'), Quantity.new(20), Custom::Date.new(1, 1, 2023))
        line1 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(2))
        line2 = OrderLine.new(OrderId.new('ABC'), Sku.new('SMALL-TABLE'), Quantity.new(2))

        batch.allocate(line1)
        batch.allocate(line2)

        expect(batch.available_quantity).to eq Quantity.new(18)
      end
  end

  describe '#allocable?' do
    context 'when the order line quantity is available and the SKU of the order match the SKU of the batch' do
      it 'returns true' do
        batch = Batch.new(Reference.new('REF'), Sku.new('TABLE'), Quantity.new(4), Custom::Date.new(1, 1, 2023))
        line = OrderLine.new(OrderId.new('ABC'), Sku.new('TABLE'), Quantity.new(2))

        expect(batch.allocable? line).to be_truthy
      end
    end

    context 'when the SKU does not match' do
      it 'returns true' do
        batch = Batch.new(Reference.new('REF'), Sku.new('LAMP'), Quantity.new(4), Custom::Date.new(1, 1, 2023))
        line = OrderLine.new(OrderId.new('ABC'), Sku.new('TABLE'), Quantity.new(2))

        expect(batch.allocable? line).to be_falsey
      end
    end

    context 'when there is not enough quantity' do
      it 'returns true' do
        batch = Batch.new(Reference.new('REF'), Sku.new('OTHER'), Quantity.new(1), Custom::Date.new(1, 1, 2023))
        line = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(2))

        expect(batch.allocable? line).to be_falsey
      end
    end

    context 'when the quantity reaches 0' do
      it 'returns true' do
        batch = Batch.new(Reference.new('REF'), Sku.new('OTHER'), Quantity.new(1), Custom::Date.new(1, 1, 2023))
        line = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(1))

        expect(batch.allocable? line).to be_truthy
      end
    end
  end

  describe '#deallocate' do
    it 'removes the allocated lines' do
      batch = Batch.new(Reference.new('REF'), Sku.new('OTHER'), Quantity.new(3), Custom::Date.new(1, 1, 2023))
      line = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(1))

      batch.allocate line
      batch.deallocate line

      expect(batch.available_quantity).to eq Quantity.new(3)
    end

    it 'remove line only if it was allocated' do
      batch = Batch.new(Reference.new('REF'), Sku.new('OTHER'), Quantity.new(3), Custom::Date.new(1, 1, 2023))
      line1 = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(1))
      line2 = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(2))

      batch.allocate line1
      batch.deallocate line2

      expect(batch.available_quantity).to eq Quantity.new(2)
    end

    it 'removes only the given order line' do
      batch = Batch.new(Reference.new('REF'), Sku.new('OTHER'), Quantity.new(3), Custom::Date.new(1, 1, 2023))
      line1 = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(1))
      line2 = OrderLine.new(OrderId.new('ABC'), Sku.new('OTHER'), Quantity.new(2))

      batch.allocate line1
      batch.allocate line2
      batch.deallocate line2

      expect(batch.available_quantity).to eq Quantity.new(2)
    end
  end
end