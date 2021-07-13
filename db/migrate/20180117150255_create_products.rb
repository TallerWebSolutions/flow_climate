# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.integer :customer_id, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :products, :customers, column: :customer_id

    add_column :projects, :product_id, :integer
    add_index :projects, :product_id
    add_foreign_key :projects, :products, column: :product_id
  end
end
