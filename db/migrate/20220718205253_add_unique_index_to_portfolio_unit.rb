# frozen_string_literal: true

class AddUniqueIndexToPortfolioUnit < ActiveRecord::Migration[7.0]
  def change
    add_index :portfolio_units, %i[name product_id parent_id], name: 'idx_portfolio_unit_name'
  end
end
