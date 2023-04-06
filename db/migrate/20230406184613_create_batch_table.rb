class CreateBatchTable < ActiveRecord::Migration[6.0]
  def change
    create_table :batches do |t|
      t.string :reference
      t.string :sku
      t.integer :quantity
      t.string :eta
    end
  end
end