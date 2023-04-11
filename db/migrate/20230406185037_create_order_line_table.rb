class CreateOrderLineTable < ActiveRecord::Migration[6.0]
  def change
    create_table :order_lines do |t|
      t.string :order_id
      t.string :sku
      t.integer :quantity
      t.bigint :batch_id
    end
  end
end