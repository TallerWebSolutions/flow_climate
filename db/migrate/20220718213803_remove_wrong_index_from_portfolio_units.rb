# frozen_string_literal: true

class RemoveWrongIndexFromPortfolioUnits < ActiveRecord::Migration[7.0]
  def change
    remove_index :portfolio_units, %i[name product_id]
  end
end
