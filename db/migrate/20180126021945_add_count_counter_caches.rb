# frozen_string_literal: true

class AddCountCounterCaches < ActiveRecord::Migration[5.1]
  def change
    change_table :customers, bulk: true do |t|
      t.integer :products_count, default: 0
      t.integer :projects_count, default: 0
    end

    add_column :products, :projects_count, :integer, default: 0
    add_column :companies, :customers_count, :integer, default: 0
  end
end
