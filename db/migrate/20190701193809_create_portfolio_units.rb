# frozen_string_literal: true

class CreatePortfolioUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolio_units do |t|
      t.integer :product_id, null: false, index: true
      t.integer :parent_id, index: true

      t.string :name, null: false, index: true
      t.integer :portfolio_unit_type, null: false, index: true

      t.timestamps
    end

    add_foreign_key :portfolio_units, :portfolio_units, column: :parent_id
    add_foreign_key :portfolio_units, :products, column: :product_id

    add_index :portfolio_units, %i[name product_id], unique: true

    add_column :demands, :portfolio_unit_id, :integer
    add_index :demands, :portfolio_unit_id
    add_foreign_key :demands, :portfolio_units, column: :portfolio_unit_id
  end
end
