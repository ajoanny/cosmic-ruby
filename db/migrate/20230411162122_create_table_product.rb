class CreateTableProduct < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :sku
      t.bigint :version
    end
  end
end