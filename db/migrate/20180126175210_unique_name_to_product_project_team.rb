# frozen_string_literal: true

class UniqueNameToProductProjectTeam < ActiveRecord::Migration[5.1]
  def change
    add_index :projects, %i[product_id name], unique: true
    add_index :products, %i[customer_id name], unique: true
    add_index :customers, %i[company_id name], unique: true
    add_index :teams, %i[company_id name], unique: true
  end
end
