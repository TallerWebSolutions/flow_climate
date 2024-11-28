# frozen_string_literal: true

class CreateProductUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :product_users do |t|
      t.integer :product_id, index: true, null: false
      t.integer :user_id, index: true, null: false
      t.timestamps
    end

    add_foreign_key :product_users, :products, column: :product_id
    add_foreign_key :product_users, :users, column: :user_id
    add_index :product_users, %i[product_id user_id], unique: true
  end
end
