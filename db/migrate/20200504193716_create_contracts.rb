# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.integer :product_id, index: true, null: false
      t.integer :customer_id, index: true, null: false
      t.integer :contract_id, index: true

      t.date :start_date, null: false
      t.date :end_date

      t.integer :renewal_period, null: false, default: 0
      t.boolean :automatic_renewal, default: false, null: false

      t.integer :total_hours, null: false
      t.integer :total_value, null: false

      t.timestamps
    end

    add_foreign_key :contracts, :customers, column: :customer_id
    add_foreign_key :contracts, :products, column: :product_id
    add_foreign_key :contracts, :contracts, column: :contract_id

    add_column :customers, :customer_id, :integer
    add_index :customers, :customer_id
    add_foreign_key :customers, :customers, column: :customer_id
  end
end
