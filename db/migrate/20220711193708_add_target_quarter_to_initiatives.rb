# frozen_string_literal: true

class AddTargetQuarterToInitiatives < ActiveRecord::Migration[7.0]
  def change
    change_table :initiatives, bulk: true do |t|
      t.integer :target_quarter, default: 1, null: false, index: true
      t.integer :target_year, default: 2022, null: false, index: true
    end
  end
end
