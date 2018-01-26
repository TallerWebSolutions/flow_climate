# frozen_string_literal: true

class AddCountCounterCaches < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :products_count, :integer, default: 0
    add_column :customers, :projects_count, :integer, default: 0

    add_column :products, :projects_count, :integer, default: 0

    add_column :companies, :customers_count, :integer, default: 0
  end
end
