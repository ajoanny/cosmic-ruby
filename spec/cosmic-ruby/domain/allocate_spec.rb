require 'cosmic-ruby/domain/batch'
require 'cosmic-ruby/domain/order_line'
require 'cosmic-ruby/domain/order_id'
require 'cosmic-ruby/domain/errors/empty_batch'
require 'cosmic-ruby/domain/errors/out_of_stock'
require 'cosmic-ruby/domain/quantity'
require 'cosmic-ruby/domain/reference'
require 'cosmic-ruby/domain/sku'
require 'cosmic-ruby/domain/date'
require 'cosmic-ruby/domain/allocate'


describe 'allocate' do
  it 'allocate the order line to current batch' do
    currentBatch = Batch.new Reference.new('REF1'), Sku.new('A'), Quantity.new(100), nil
    otherBatch = Batch.new Reference.new('REF2'), Sku.new('A'), Quantity.new(100), Custom::Date.new(1, 1, 2000)
    line = OrderLine.new OrderId.new('ID'), Sku.new('A'), Quantity.new(10)

    allocate(line, [currentBatch, otherBatch])

    expect(currentBatch.available_quantity).to eq Quantity.new(90)
    expect(currentBatch.available_quantity).to eq Quantity.new(90)
  end

  it 'allocate the order line to the earliest batch' do
    earliestBatch = Batch.new Reference.new('REF1'), Sku.new('A'), Quantity.new(100), Custom::Date.new(1, 1, 2000)
    mediumBatch = Batch.new Reference.new('REF2'), Sku.new('A'), Quantity.new(100), Custom::Date.new(1, 1, 2001)
    latestBatch = Batch.new Reference.new('REF3'), Sku.new('A'), Quantity.new(100), Custom::Date.new(1, 1, 2002)
    line = OrderLine.new OrderId.new('ID'), Sku.new('A'), Quantity.new(10)

    allocate(line, [mediumBatch, earliestBatch, latestBatch])

    expect(earliestBatch.available_quantity).to eq Quantity.new(90)
    expect(mediumBatch.available_quantity).to eq Quantity.new(100)
    expect(latestBatch.available_quantity).to eq Quantity.new(100)
  end

  it 'allocate the order line to the earliest batch where the line is allocable' do
    earliestBatch = Batch.new Reference.new('REF1'), Sku.new('A'), Quantity.new(1), Custom::Date.new(1, 1, 2000)
    mediumBatch = Batch.new Reference.new('REF2'), Sku.new('A'), Quantity.new(2), Custom::Date.new(1, 1, 2001)
    latestBatch = Batch.new Reference.new('REF3'), Sku.new('A'), Quantity.new(100), Custom::Date.new(1, 1, 2002)
    line = OrderLine.new OrderId.new('ID'), Sku.new('A'), Quantity.new(10)

    allocate(line, [mediumBatch, earliestBatch, latestBatch])

    expect(earliestBatch.available_quantity).to eq Quantity.new(1)
    expect(mediumBatch.available_quantity).to eq Quantity.new(2)
    expect(latestBatch.available_quantity).to eq Quantity.new(90)
  end

  it 'return the reference of the used batch' do
    earliestBatch = Batch.new Reference.new('REF1'), Sku.new('A'), Quantity.new(1), Custom::Date.new(1, 1, 2000)
    mediumBatch = Batch.new Reference.new('REF2'), Sku.new('A'), Quantity.new(2), Custom::Date.new(1, 1, 2001)
    latestBatch = Batch.new Reference.new('REF3'), Sku.new('A'), Quantity.new(1), Custom::Date.new(1, 1, 2002)
    line = OrderLine.new OrderId.new('ID'), Sku.new('A'), Quantity.new(2)

    reference = allocate(line, [mediumBatch, earliestBatch, latestBatch])

    expect(reference).to eq Reference.new('REF2')
  end

  it 'raises an exception when there is no batch available' do
    batch = Batch.new Reference.new('REF1'), Sku.new('A'), Quantity.new(1), Custom::Date.new(1, 1, 2000)
    line = OrderLine.new OrderId.new('ID'), Sku.new('A'), Quantity.new(2)
    exception = OutOfStock.new

    expect { allocate(line, [batch]) }.to raise_error(exception)
  end
end