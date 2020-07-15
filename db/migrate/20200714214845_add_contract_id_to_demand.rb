# frozen_string_literal: true

class AddContractIdToDemand < ActiveRecord::Migration[6.0]
  def change
    change_table :demands, bulk: true do |t|
      t.integer :contract_id, null: true, index: true
    end

    add_foreign_key :demands, :contracts, column: :contract_id
  end
end
