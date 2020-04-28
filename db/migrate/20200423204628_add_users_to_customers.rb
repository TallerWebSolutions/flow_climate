# frozen_string_literal: true

class AddUsersToCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers_users do |t|
      t.integer :customer_id, index: true, null: false
      t.integer :user_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :customers_users, :customers, column: :customer_id
    add_foreign_key :customers_users, :users, column: :user_id
    add_index :customers_users, %i[customer_id user_id], unique: true, name: 'idx_customers_users_unique'
  end
end
