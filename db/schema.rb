# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_04_11_162122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: :cascade do |t|
    t.string "reference"
    t.string "sku"
    t.integer "quantity"
    t.string "eta"
    t.bigint "product_id"
  end

  create_table "order_lines", force: :cascade do |t|
    t.string "order_id"
    t.string "sku"
    t.integer "quantity"
    t.bigint "batch_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "sku"
    t.bigint "version"
  end

end
