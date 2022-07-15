# frozen_string_literal: true

class AddExternalIdToPortfolioUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :portfolio_units, :external_id, :string
    add_index :portfolio_units, :external_id

    add_index :work_item_types, %i[company_id item_level name], unique: true
  end
end
