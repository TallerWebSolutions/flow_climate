# frozen_string_literal: true

class AddProductToDemand < ActiveRecord::Migration[5.2]
  def up
    change_table :demands, bulk: true do |t|
      t.integer :product_id, index: true
    end

    add_foreign_key :demands, :products, column: :product_id
  end

  def down
    remove_column :demands, :product_id
  end
end
