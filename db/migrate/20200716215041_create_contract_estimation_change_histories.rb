# frozen-string-literal: true

class CreateContractEstimationChangeHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :contract_estimation_change_histories do |t|
      t.integer :contract_id, null: false
      t.datetime :change_date, null: false
      t.integer :hours_per_demand, null: false

      t.timestamps
    end

    add_foreign_key :contract_estimation_change_histories, :contracts, column: :contract_id
  end
end
