# frozen_string_literal: true

class CreateContractConsolidations < ActiveRecord::Migration[6.0]
  def change
    create_table :contract_consolidations do |t|
      t.integer :contract_id, index: true, null: false

      t.date :consolidation_date, index: true, null: false
      t.decimal :operational_risk_value, null: false

      t.timestamps
    end

    add_foreign_key :contract_consolidations, :contracts, column: :contract_id
    add_index :contract_consolidations, %i[contract_id consolidation_date], unique: true, name: 'idx_contract_consolidation_unique'
  end
end
